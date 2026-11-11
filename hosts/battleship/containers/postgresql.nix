{config, ...}: let
  hostCfg = config;
in {
  containers.postgresql.autoStart = true;
  containers.postgresql.privateNetwork = true;
  containers.postgresql.privateUsers = "pick";
  containers.postgresql.hostAddress = "192.168.0.101";
  containers.postgresql.localAddress = "10.0.1.1";
  containers.postgresql.forwardPorts = [
    {
      containerPort = 5432;
      hostPort = 5433;
      protocol = "tcp";
    }
  ];
  containers.postgresql.config = {
    config,
    pkgs,
    lib,
    ...
  }:
    with lib; {
      services.postgresql.enable = true;
      services.postgresql.enableTCPIP = true;
      services.postgresql.package = pkgs.postgresql_18;
      services.postgresql.settings = {
        port = 5432;
        ssl = false;
      };
      services.postgresql.ensureDatabases =
        []
        ++ (map (v: v.name) (filter (v: v.ensureDBOwnership)
            config.services.postgresql.ensureUsers));
      services.postgresql.ensureUsers = [
      ];
      services.postgresql.authentication = lib.mkForce ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust
        host    all             all             0.0.0.0/0               scram-sha-256
        host    all             all             ::/0                    scram-sha-256
      '';

      services.postgresqlBackup.enable = true;
      services.postgresqlBackup.backupAll = true;
      services.postgresqlBackup.compressionLevel = 9;
      services.postgresqlBackup.startAt = "*-*-* 02:00:00 ${hostCfg.time.timeZone}";
      services.postgresqlBackup.location = "/run/media/cryptstorage/postgresql-backups";

      networking.firewall.allowedTCPPorts = [config.services.postgresql.settings.port];
      networking.firewall.allowedUDPPorts = [config.services.postgresql.settings.port];
      networking.defaultGateway.address = "192.168.0.101";
      networking.useHostResolvConf = mkForce false;

      environment.systemPackages = with pkgs; [lazysql];

      system.stateVersion = "26.05";
    };
  containers.postgresql.bindMounts = {
    cryptstorage-postgresql-dumps = {
      hostPath = "/run/media/cryptstorage/postgresql-backups";
      mountPoint = "/run/media/cryptstorage/postgresql-backups";
      isReadOnly = false;
    };
  };

  systemd.tmpfiles.rules = [
    "d /run/media/cryptstorage/postgresql-backups 0775 root root"
  ];
}
