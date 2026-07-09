{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.garage;
in {
  options.services.garage.settings = {
    s3_api.api_bind_port = mkOption {
      type = with types; port;
    };
    s3_web.bind_port = mkOption {
      type = with types; port;
    };
    k2v_api.api_bind_port = mkOption {
      type = with types; port;
    };
    rpc_bind_port = mkOption {
      type = with types; port;
    };
  };
  config = {
    services.garage.enable = true;
    services.garage.package = pkgs.garage_2;
    services.garage.settings = {
      compression_level = 8;
      db_engine = "sqlite";
      metadata_fsync = true;
      replication_factor = 1;

      data_fsycn = true;
      data_dir = [
        {
          capacity = "400G";
          path = "/var/lib/garage/data";
        }
      ];

      admin.api_bind_addr = "[::]:3460";
      admin.admin_token_file = config.sops.secrets."services/garage/admin_token".path;
      admin.metrics_token_file = config.sops.secrets."services/garage/metrics_token".path;

      s3_api.s3_region = "garage";
      s3_api.api_bind_port = 3461;
      s3_api.api_bind_addr = "[::]:3461";
      s3_api.root_domain = ".s3.garage.local";

      s3_web.index = "index.html";
      s3_web.bind_port = 3462;
      s3_web.bind_addr = "[::]:3462";
      s3_web.root_domain = ".web.garage.local";

      k2v_api.api_bind_port = 3463;
      k2v_api.api_bind_addr = "[::]:3463";

      rpc_bind_port = 3464;
      rpc_bind_addr = "[::]:3464";
      rpc_public_addr = "127.0.0.1:3464";
      rpc_secret_file = config.sops.secrets."services/garage/rpc_secret".path;
    };

    systemd.services.garage.serviceConfig = {
      User = "garage";
      Group = "garage";
      DynamicUser = false;
      StateDirectory = mkForce null;
    };

    users.users.garage = {
      isSystemUser = true;
      group = "garage";
    };
    users.groups.garage = {};

    users.users.guz.packages = [
      (pkgs.writeShellScriptBin "s3" ''
        export AWS_ACCESS_KEY_ID="$(cat ${config.sops.secrets."services/garage/admin_key".path})"
        export AWS_SECRET_ACCESS_KEY="$(cat ${config.sops.secrets."services/garage/admin_secret".path})"
        export AWS_DEFAULT_REGION='${cfg.settings.s3_api.s3_region}'
        export AWS_ENDPOINT_URL='http://localhost:${toString cfg.settings.s3_api.api_bind_port}'
        ${lib.getExe pkgs.awscli2} s3 "$@"
      '')
    ];

    services.caddy.virtualHosts = {
      "${removePrefix "." cfg.settings.s3_api.root_domain}".extraConfig = ''
        reverse_proxy http://192.168.0.103:${toString cfg.settings.s3_api.api_bind_port}
        tls internal
      '';
      "${removePrefix "." cfg.settings.s3_web.root_domain}".extraConfig = ''
        reverse_proxy http://192.168.0.103:${toString cfg.settings.s3_web.bind_port}
        tls internal
      '';
      "*.${removePrefix "." cfg.settings.s3_web.root_domain}".extraConfig = ''
        reverse_proxy http://192.168.0.103:${toString cfg.settings.s3_web.bind_port}
        tls internal
      '';
    };

    networking.firewall.allowedTCPPorts = [
      cfg.settings.s3_web.bind_port
      cfg.settings.s3_api.api_bind_port
    ];
    networking.firewall.allowedUDPPorts = [
      cfg.settings.s3_web.bind_port
      cfg.settings.s3_api.api_bind_port
    ];

    sops.secrets = {
      "services/garage/admin_key" = {owner = "garage";};
      "services/garage/admin_secret" = {owner = "garage";};
      "services/garage/admin_token" = {owner = "garage";};
      "services/garage/metrics_token" = {owner = "garage";};
      "services/garage/rpc_secret" = {owner = "garage";};
    };
  };
}
