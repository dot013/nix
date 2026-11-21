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
        [
          "postiz-temporal-visibility"
        ]
        ++ (map (v: v.name) (filter (v: v.ensureDBOwnership)
            config.services.postgresql.ensureUsers));
      services.postgresql.ensureUsers = [
        {
          name = "kitsu";
          ensureClauses = {
            login = true;
            password = "SCRAM-SHA-256$4096:QK/rhDDwi/B8IkiDqPd33w==$9kgXMv3dYzIdzF6QzfP5JIu2APzW3Nc28ycjQ4o91Ms=:pVu3+dRfacT64qpq+Zo2TbhRe2Mj+eKBCk1Ls2uFF90=";
          };
          ensureDBOwnership = true;
        }
        {
          name = "postiz";
          ensureClauses = {
            login = true;
            password = "SCRAM-SHA-256$4096:tahwvA3iHTF/pXe3zBtl7w==$lpQgM9l2OT+8TVM7J5xeFG61NeM6QTPoxAZWHvShTDI=:UJioQNAJZ9//hZNseOBQvLIYnimMrgNQnZ+jtaN6ZFs=";
          };
          ensureDBOwnership = true;
        }
        {
          name = "postiz-temporal";
          ensureClauses = {
            login = true;
            password = "SCRAM-SHA-256$4096:FKDqN5ePwiRc5YIVy8XzBg==$mM+M9G4a7CFslGtP3PzEP2FY5FCp8OlsxYEdq1bpkkA=:m+dMvwTrIfGNaJCJnQffa733CCl5zp3voSo3mUYUStY=";
          };
          ensureDBOwnership = true;
        }
      ];
      systemd.services.postgresql-setup.postStart = ''
        echo "Setting up postiz-temporal ownership"
        psql -f ${pkgs.writeText "postgres-setup-postiz-temporal.sql" ''
          ALTER DATABASE "postiz-temporal" OWNER TO "postiz-temporal";
          ALTER DATABASE "postiz-temporal-visibility" OWNER TO "postiz-temporal";

          \connect "postiz-temporal-visibility"
          REASSIGN OWNED BY "postiz-temporal-visibility" TO "postiz-temporal";
          ALTER SCHEMA public OWNER TO "postiz-temporal";
          GRANT ALL ON SCHEMA public TO "postiz-temporal";
          GRANT ALL ON ALL TABLES IN SCHEMA public TO "postiz-temporal";
          GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO "postiz-temporal";
          ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "postiz-temporal";
          ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO "postiz-temporal";

          \connect "postiz-temporal"
          REASSIGN OWNED BY "postiz-temporal-visibility" TO "postiz-temporal";
          ALTER SCHEMA public OWNER TO "postiz-temporal";
          GRANT ALL ON SCHEMA public TO "postiz-temporal";
          GRANT ALL ON ALL TABLES IN SCHEMA public TO "postiz-temporal";
          GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO "postiz-temporal";
          ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "postiz-temporal";
          ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO "postiz-temporal";
        ''}
      '';
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
