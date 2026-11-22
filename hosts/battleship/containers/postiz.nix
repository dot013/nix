{
  config,
  lib,
  inputs,
  self,
  pkgs,
  ...
}:
with lib; let
  hostCfg = config;
in {
  services.caddy.virtualHosts."postiz.capytal.cc:80".extraConfig = ''
    import capytal-auth

    reverse_proxy ${config.containers.postiz.localAddress}:5000 {
      header_up X-Real-IP {header.Cf-Connecting-Ip}
      header_up X-Forwarded-For {header.Cf-Connecting-Ip}
      header_up X-Forwarded-Proto https
      header_up Reload {http.request.header.Reload}
      header_up Onboarding {http.request.header.Onboarding}
      header_up Activate {http.request.header.Activate}
      header_up Auth {http.request.header.Auth}
      header_up Showorg {http.request.header.Showorg}
      header_up Impersonate {http.request.header.Impersonate}
      header_up Accept-Language {http.request.header.Accept-Language}
      header_up i18next {http.request.header.i18next}
    }
  '';

  containers.postiz.autoStart = true;
  containers.postiz.privateNetwork = true;
  containers.postiz.hostAddress = "192.168.0.101";
  containers.postiz.localAddress = "10.0.4.4";
  containers.postiz.extraFlags = [
    "--property=MemoryMax=4G"
    "--property=CPUQuota=200%" # One core
  ];
  containers.postiz.config = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.services.postiz
    ];

    services.postiz.enable = true;
    services.postiz.configureRedis = true;
    services.postiz.runMigrate = true;
    services.postiz.environment = mapAttrs (_: v: toString v) {
      MAIN_URL = "https://postiz.capytal.cc";
      FRONTEND_URL = "https://postiz.capytal.cc";
      NEXT_PUBLIC_BACKEND_URL = "https://postiz.capytal.cc/api";
      BACKEND_INTERNAL_URL = "http://localhost:3000";

      TEMPORAL_ADDRESS = "localhost:7233";
      IS_GENERAL = "true";
      # DISABLE_REGISTRATION = "true";

      NX_ADD_PLUGINS = "false";
    };
    services.postiz.environmentFile = config.sops.secrets."containers/postiz/env".path;
    systemd.services."postiz-backend" = {
      after = ["temporal.service" "temporal-postiz-namespace.service"];
      requires = ["temporal.service" "temporal-postiz-namespace.service"];
    };
    systemd.services."postiz-migrate" = {
      after = ["temporal.service" "temporal-postiz-namespace.service"];
      requires = ["temporal.service" "temporal-postiz-namespace.service"];
    };

    services.temporal.enable = true;
    services.temporal.settings = {
      persistence = {
        defaultStore = "default";
        visibilityStore = "default-visibility";
        numHistoryShards = 1;
        datastores = {
          default.sql = {
            pluginName = "postgres12";
            user = "postiz-temporal";
            password = ''{{ env "POSTGRES_PWD" }}'';
            databaseName = "postiz-temporal";
            connectAddr = "192.168.0.101:5433";
            connectProtocol = "tcp";
            maxConns = 1;
            maxIdleConns = 1;
            maxConnLifetime = "1h";
            tls.enabled = false;
          };
          default-visibility.sql = {
            pluginName = "postgres12";
            user = "postiz-temporal";
            password = ''{{ env "POSTGRES_PWD" }}'';
            databaseName = "postiz-temporal-visibility";
            connectAddr = "192.168.0.101:5433";
            connectProtocol = "tcp";
            maxConns = 1;
            maxIdleConns = 1;
            maxConnLifetime = "1h";
            tls.enabled = false;
          };
        };
      };
      global = {
        membership = {
          maxJoinDuration = "30s";
          broadcastAddress = "127.0.0.1";
        };
        pprof.port = 7936;
        metrics.prometheus = {
          framework = "tally";
          timerType = "histogram";
          listenAddress = "127.0.0.1:8000";
        };
      };
      services = listToAttrs (imap0 (i: n:
        nameValuePair n {
          rpc = {
            grpcPort = 7233 + i;
            membershipPort = 6933 + i;
            httpPort = 7243 + i;
            bindOnLocalHost = true;
          };
        }) ["frontend" "matching" "history" "worker"]);
      clusterMetadata = {
        enableGlobalNamespace = false;
        failoverVersionIncrement = 10;
        masterClusterName = "active";
        currentClusterName = "active";
        clusterInformation.active = {
          enabled = true;
          initialFailoverVersion = 1;
          rpcName = "frontend";
          rpcAddress = "localhost:7233";
          httpAddress = "localhost:7243";
        };
      };
      dcRedirectionPolicy.policy = "noop";
      archival = {
        history = {
          state = "enabled";
          enableRead = true;
          provider.filestore = {
            fileMode = "0666";
            dirMode = "0766";
          };
        };
        visibility = {
          state = "enabled";
          enableRead = true;
          provider.filestore = {
            fileMode = "0666";
            dirMode = "0766";
          };
        };
      };
      namespaceDefaults = {
        archival = {
          history = {
            state = "disabled";
            URI = "file://${config.services.temporal.dataDir}/archival/history";
          };
          visibility = {
            state = "disabled";
            URI = "file://${config.services.temporal.dataDir}/archival/visibility";
          };
        };
      };
      dynamicConfigClient = {
        filepath = "${pkgs.writers.writeYAML "temporal-dynamicconfig.yaml" {
          "limit.maxIDLength" = [
            {
              value = 255;
              constraints = {};
            }
          ];
          "system.forceSearchAttributesCacheRefreshOnRead" = [
            {
              value = true;
              constraints = {};
            }
          ];
        }}";
        pollInterval = "10s";
      };
    };
    systemd.services."temporal" = {
      before = ["postiz.target"];
      path = [pkgs.temporal pkgs.netcat];
      # HACK: don't block container boot readiness. Temporal ExecStartPre needs PG
      # over the host veth, but host veth setup runs in ExecStartPost after READY=1.
      wantedBy = mkForce [];
      preStart = ''
        set -eu

        mkdir -p ${config.services.temporal.dataDir}
        mkdir -p ${config.services.temporal.dataDir}/archival
        mkdir -p ${config.services.temporal.dataDir}/archival/history
        mkdir -p ${config.services.temporal.dataDir}/archival/visibility

        # for _ in $(seq 1 60); do
        #   if nc -z -w 2 192.168.0.101 5433; then
        #     break
        #   fi
        #   echo 'Waiting for PostgreSQL port to be available...'
        #   sleep 2
        # done
        nc -z -w 2 192.168.0.101 5433 || {
          echo 'PostgreSQL port did not become available in time' >&2
          exit 1
        }
        echo 'PostgreSQL port is available'

        # Create and setup temporal database
        echo "Setting up temporal database"
        temporal-sql-tool --plugin postgres12 --ep 192.168.0.101 -u postiz-temporal \
          -p 5433 --db postiz-temporal setup-schema -v 0.0
        temporal-sql-tool --plugin postgres12 --ep 192.168.0.101 -u postiz-temporal \
          -p 5433 --db postiz-temporal update-schema \
          -d ${pkgs.temporal}/share/schema/postgresql/v12/temporal/versioned

        echo "Setting up visibility database"
        # Create and setup visibility database
        temporal-sql-tool --plugin postgres12 --ep 192.168.0.101 -u postiz-temporal \
          -p 5433 --db postiz-temporal-visibility setup-schema -v 0.0
        temporal-sql-tool --plugin postgres12 --ep 192.168.0.101 -u postiz-temporal \
          -p 5433 --db postiz-temporal-visibility update-schema \
          -d ${pkgs.temporal}/share/schema/postgresql/v12/visibility/versioned

        echo 'PostgreSQL schema setup complete'
      '';
      environment = mapAttrs (_: v: toString v) {
        TEMPORAL_NAMESPACE = "default";
        TEMPORAL_HOST = "localhost:7233";
        TEMPORAL_ADDRESS = "localhost:7233";
        DB = "postgres12";
        DBNAME = "postiz-temporal";
        VISIBILITY_DBNAME = "postiz-temporal-visibility";
        DB_PORT = "5433";
        POSTGRES_SEEDS = "192.168.0.101";
        POSTGRES_USER = "postiz-temporal";
        POSTGRES_TLS_ENABLED = "false";
        BIND_ON_IP = "127.0.0.1";
      };
      serviceConfig = {
        TimeoutStartSec = "5min";
        EnvironmentFile = [
          config.sops.secrets."containers/postiz/temporal/env".path
        ];
      };
    };
    systemd.services."temporal-postiz-namespace" = {
      wantedBy = ["temporal.service"];
      after = ["network-online.target" "temporal.service"];
      wants = ["network-online.target" "temporal.service"];
      requires = ["temporal.service"];
      before = ["postiz.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = config.services.temporal.user;
        Group = config.services.temporal.group;
        TimeoutStartSec = "5min";
        Restart = "on-failure";
        RestartSec = "10s";
      };
      environment = {
        DEFAULT_NAMESPACE = "default";
        NAMESPACE = "default";
        TEMPORAL_ADDRESS = "localhost:7233";
      };
      path = [pkgs.netcat pkgs.temporal-cli];
      script = readFile (pkgs.fetchurl {
        url = "https://github.com/temporalio/temporal-server-operations/raw/ef7ed9d4d94d72d4110bd69c37f2c46fca6b63d9/compose/scripts/create-namespace.sh";
        hash = "sha256-oMQXXrMzJp3sa1k9+N2gdAbaGwsjRXxtmg6BFTbFtBk=";
      });
    };
    environment.etc."temporal/temporal-server.yaml".source = mkForce (
      pkgs.writeText "temporal-server-templated.yaml" ''
        # enable-template
        ${readFile (pkgs.writers.writeYAML "settings.yaml" config.services.temporal.settings)}
      ''
    );

    # HACK: Temporal fails during boot, since, for some reason, the network interface
    # isn't available yet. However, after boot finishes, restarting it, and it's depending
    # services can start.
    # INFO: MAYBE NEEDS TO BE RERUN MANUALLY AFTER RESTART
    systemd.services."temporal-start-hacky" = {
      after = ["multi-user.target"];
      requires = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
      };
      script = ''
        systemctl reset-failed temporal.service
        systemctl restart temporal.service
        systemctl reset-failed temporal-postiz-namespace.service
        systemctl restart temporal-postiz-namespace.service
        systemctl reset-failed postiz-migrate.service
        systemctl restart postiz-migrate.service
        systemctl reset-failed postiz-backend.service
        systemctl restart postiz-backend.service
        systemctl reset-failed postiz-frontend.service
        systemctl restart postiz-frontend.service
      '';
    };

    services.redis.package = pkgs.valkey;

    services.nginx.enable = true;
    services.nginx.user = config.services.postiz.user;
    services.nginx.group = config.services.postiz.group;
    services.nginx.config =
      pipe (readFile (pkgs.fetchurl {
        url = "https://github.com/gitroomhq/postiz-app/raw/6be4874631fea453f99115a78fd543c71820ab45/var/docker/nginx.conf";
        hash = "sha256-Peh4TsADFCft0YseQM97y4pgV0QaeHXulKKsKkJkBTo=";
      })) [
        (replaceString "alias /uploads/;" "alias ${config.services.postiz.stateDir}/uploads/;")
        (replaceString "www;" "${config.services.postiz.user};")
        (replaceString "/etc/nginx/mime.types;" "${pkgs.fetchurl {
          url = "https://github.com/nginx/nginx/raw/2e8440bcdc438f0f1cd03da778a3843ddb3c86d9/conf/mime.types";
          hash = "sha256-b5XR19dePAcpB9hFYipp0jEQ0SZsFv8SKzEJuLIfOuk=";
        }};")
      ];

    users.users.${config.services.temporal.user} = {
      isSystemUser = true;
      group = config.services.temporal.user;
    };
    users.groups.${config.services.temporal.user} = {};

    sops.defaultSopsFile = hostCfg.sops.defaultSopsFile;
    sops.defaultSopsFormat = hostCfg.sops.defaultSopsFormat;
    sops.age.keyFile = "/run/key.txt";
    sops.secrets = {
      "containers/postiz/env" = {
        owner = config.services.postiz.user;
        restartUnits = ["postiz.target"];
      };
      "containers/postiz/temporal/env" = {
        owner = config.services.temporal.user;
        restartUnits = ["temporal.service"];
      };
    };

    environment.systemPackages = [pkgs.netcat];

    networking.firewall.allowedTCPPorts = [5000];
    networking.firewall.allowedUDPPorts = [5000];

    # Use systemd-resolved inside the container
    # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
    networking.useHostResolvConf = mkForce false;
    networking.nameservers = ["192.168.0.101"];
    networking.defaultGateway = {
      address = "192.168.0.101";
      interface = "eth0";
    };

    system.stateVersion = "26.05";
  };
  containers.postiz.bindMounts = {
    key-txt = {
      hostPath = hostCfg.sops.age.keyFile;
      mountPoint = "/run/key.txt";
      isReadOnly = true;
    };
  };

  systemd.services."container@postiz.service" = {
    after = ["container@postgresql.service"];
    requires = ["container@postgresql.service"];
  };
  systemd.services."temporal-hacky-restart-container@postiz" = {
    wantedBy = ["container@postiz.service"];
    after = ["container@postiz.service"];
    requires = ["container@postiz.service"];
    path = [pkgs.nixos-container];
    script = ''
      nixos-container run postiz -- systemctl start --force --now temporal-start-hacky
    '';
    serviceConfig = {
      Type = "simple";
    };
  };
}
