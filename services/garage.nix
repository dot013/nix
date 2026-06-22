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
    s3_api.bind_port = mkOption {
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
      s3_api.bind_port = 3461;
      s3_api.bind_addr = "[::]:3461";
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
      # packages = with pkgs; [
      #   (symlinkJoin {
      #     name = "garagecli";
      #     buildInputs = [makeWrapper];
      #     postBuild = ''
      #       wrapProgram "$out/bin/aws" \
      #         --set-default 'AWS_ACCESS_KEY_ID' "$(cat ${config.sops.secrets."garage/admin_key".path})" \
      #         --set-default 'AWS_SECRET_ACCESS_KEY' "$(cat ${config.sops.secrets."garage/admin_secret".path})" \
      #         --set-default 'AWS_DEFAULT_REGION' '${cfg.settings.s3_api.s3_region}' \
      #         --set-default 'AWS_ENDPOINT_URL' "http://localhost:${parsePort cfg.settings.s3_api.bind_addr}"
      #     '';
      #   })
      # ];
    };
    users.groups.garage = {};

    services.caddy.virtualHosts = {
      "${removePrefix "." cfg.settings.s3_api.root_domain}".extraConfig = ''
        reverse_proxy http://spacestation:${toString cfg.settings.s3_api.bind_port}
        tls internal
      '';
      "${removePrefix "." cfg.settings.s3_web.root_domain}".extraConfig = ''
        reverse_proxy http://spacestation:${toString cfg.settings.s3_web.bind_port}
        tls internal
      '';
      "*.${removePrefix "." cfg.settings.s3_web.root_domain}".extraConfig = ''
        reverse_proxy http://spacestation:${toString cfg.settings.s3_web.bind_port}
        tls internal
      '';
    };

    networking.firewall.allowedTCPPorts = [
      cfg.settings.s3_web.bind_port
      cfg.settings.s3_api.bind_port
    ];
    networking.firewall.allowedUDPPorts = [
      cfg.settings.s3_web.bind_port
      cfg.settings.s3_api.bind_port
    ];

    sops.secrets = {
      "services/garage/admin_token" = {owner = "garage";};
      "services/garage/metrics_token" = {owner = "garage";};
      "services/garage/rpc_secret" = {owner = "garage";};
    };
  };
}
