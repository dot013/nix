{
  config,
  lib,
  ...
}: {
  services.caddy.virtualHosts."http://s3.garage.local".extraConfig = lib.mkForce ''
    reverse_proxy 192.168.0.101:3461
  '';
  services.caddy.virtualHosts."http://web.garage.local".extraConfig = lib.mkForce ''
    reverse_proxy 192.168.0.101:3462
  '';
  services.caddy.virtualHosts."http://rpc.garage.local".extraConfig = lib.mkForce ''
    reverse_proxy 192.168.0.101:3464
  '';

  containers.garage.autoStart = true;
  # containers.garage.privateNetwork = true;
  containers.garage.privateUsers = "pick";
  containers.garage.hostAddress = "192.168.0.101";
  containers.garage.localAddress = "192.168.0.112";
  containers.garage.extraFlags = [
    "--load-credential=env:${config.sops.secrets."containers/garage/env".path}"
    "--bind=/run/media/cryptstorage/garage:/var/lib/garage:idmap"
  ];
  containers.garage.config = {
    config,
    pkgs,
    lib,
    ...
  }:
    with lib; let
      admin_port = 3460;
      api_port = admin_port + 1;
      web_port = admin_port + 2;
      k2v_port = admin_port + 3;
      rpc_port = admin_port + 4;
    in {
      services.garage.enable = true;
      services.garage.package = pkgs.garage_2;
      services.garage.environmentFile = "/run/credentials/@system/env";
      services.garage.settings = {
        compression_level = 8;
        db_engine = "sqlite";
        metadata_fsync = true;
        replication_factor = 3;

        data_fsycn = true;
        data_dir = [
          {
            capacity = "1T";
            path = "/var/lib/garage";
          }
        ];

        admin.api_bind_addr = "[::]:${toString admin_port}";
        # admin.admin_token_file = "set via env value";
        # admin.metrics_token_file = "set via env value";

        s3_api.s3_region = "garage";
        s3_api.api_bind_addr = "[::]:${toString api_port}";
        s3_api.root_domain = ".s3.garage.local";

        s3_web.index = "index.html";
        s3_web.bind_addr = "[::]:${toString web_port}";
        s3_web.root_domain = ".web.garage.local";

        k2v_api.api_bind_addr = "[::]:${toString k2v_port}";

        rpc_bind_addr = "[::]:${toString rpc_port}";
        rpc_public_addr = "100.98.115.36:${toString rpc_port}";
        # rpc_secret = "set via env value";
      };

      systemd.services."garage".serviceConfig = mkIf config.services.garage.enable {
        User = "garage";
        Group = "garage";
        DynamicUser = mkForce false;
        StateDirectory = mkForce null;
      };

      users.users."garage" = {
        group = "garage";
        isSystemUser = true;
      };
      users.groups."garage" = {};

      systemd.tmpfiles.rules = [
        "d /var/lib/garage 0775 garage garage"
      ];

      networking.firewall.allowedTCPPorts = [admin_port api_port web_port k2v_port rpc_port];
      networking.firewall.allowedUDPPorts = [admin_port api_port web_port k2v_port rpc_port];

      networking.defaultGateway = "192.168.0.101";
      networking.nameservers = ["192.168.0.101"];

      system.stateVersion = "26.05";
    };

  services.caddy.virtualHosts."s3.garage2.local:80".extraConfig = lib.mkForce ''
    reverse_proxy 192.168.0.101:3471
  '';
  services.caddy.virtualHosts."web.garage2.local:80".extraConfig = lib.mkForce ''
    reverse_proxy 192.168.0.101:3472
  '';
  services.caddy.virtualHosts."rpc.garage2.local:80".extraConfig = lib.mkForce ''
    reverse_proxy 192.168.0.101:3474
  '';

  containers.garage2.autoStart = true;
  # containers.garage2.privateNetwork = true;
  containers.garage2.privateUsers = "pick";
  containers.garage2.hostAddress = "192.168.0.101";
  containers.garage2.localAddress = "192.168.0.113";
  containers.garage2.extraFlags = [
    "--load-credential=env:${config.sops.secrets."containers/garage/env".path}"
    "--bind=/run/media/cryptstorage/garage2:/var/lib/garage:idmap"
  ];
  containers.garage2.config = {
    config,
    pkgs,
    lib,
    ...
  }:
    with lib; let
      admin_port = 3470;
      api_port = admin_port + 1;
      web_port = admin_port + 2;
      k2v_port = admin_port + 3;
      rpc_port = admin_port + 4;
    in {
      services.garage.enable = true;
      services.garage.package = pkgs.garage_2;
      services.garage.environmentFile = "/run/credentials/@system/env";
      services.garage.settings = {
        compression_level = 8;
        db_engine = "sqlite";
        metadata_fsync = true;
        replication_factor = 3;

        data_fsycn = true;
        data_dir = [
          {
            capacity = "1T";
            path = "/var/lib/garage";
          }
        ];

        admin.api_bind_addr = "[::]:${toString admin_port}";
        # admin.admin_token_file = "set via env value";
        # admin.metrics_token_file = "set via env value";

        s3_api.s3_region = "garage";
        s3_api.api_bind_addr = "[::]:${toString api_port}";
        s3_api.root_domain = ".s3.garage.local";

        s3_web.index = "index.html";
        s3_web.bind_addr = "[::]:${toString web_port}";
        s3_web.root_domain = ".web.garage.local";

        k2v_api.api_bind_addr = "[::]:${toString k2v_port}";

        rpc_bind_addr = "[::]:${toString rpc_port}";
        rpc_public_addr = "100.98.115.36:${toString rpc_port}";
        # rpc_secret = "set via env value";
      };

      systemd.services."garage".serviceConfig = mkIf config.services.garage.enable {
        User = "garage";
        Group = "garage";
        DynamicUser = mkForce false;
        StateDirectory = mkForce null;
      };

      users.users."garage" = {
        group = "garage";
        isSystemUser = true;
      };
      users.groups."garage" = {};

      systemd.tmpfiles.rules = [
        "d /var/lib/garage 0775 garage garage"
      ];

      networking.firewall.allowedTCPPorts = [admin_port api_port web_port k2v_port rpc_port];
      networking.firewall.allowedUDPPorts = [admin_port api_port web_port k2v_port rpc_port];

      networking.defaultGateway = "192.168.0.101";
      networking.nameservers = ["192.168.0.101"];

      system.stateVersion = "26.05";
    };

  users.users."garage" = {
    group = "garage";
    isSystemUser = true;
  };
  users.groups."garage" = {};

  systemd.tmpfiles.rules = [
    "d /run/media/cryptstorage/garage 0775 garage garage"
    "d /run/media/cryptstorage/garage2 0775 garage garage"
  ];

  sops.secrets = {
    "containers/garage/env" = {
      restartUnits = [
        "container@garage.service"
        "container@garage2.service"
      ];
    };
  };
}
