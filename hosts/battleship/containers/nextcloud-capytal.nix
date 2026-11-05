{
  inputs,
  config,
  lib,
  ...
}: let
  hostCfg = config;
in {
  services.caddy.virtualHosts."cloud.capytal.cc:80".extraConfig = lib.mkForce ''
    header {
      X-Content-Type-Options "nosniff"
      X-Robots-Tag "noindex,nofollow"
      X-Permitted-Cross-Domain-Policies "none"
      Referrer-Policy "no-referrer"
      Strict-Transport-Security "max-age=15552000"
    }

    redir /.well-known/carddav /remote.php/dav 302
    redir /.well-known/caldav /remote.php/dav 302

    reverse_proxy http://10.0.2.2:80 {
      header_up X-Real-IP {header.Cf-Connecting-Ip}
      header_up X-Forwarded-Host {host}
      header_up X-Forwarded-For {header.Cf-Connecting-Ip}
      header_up X-Forwarded-Proto https
      header_up X-Http-Version {http.request.proto}
      header_up Host {host}
    }
  '';
  services.caddy.virtualHosts."talk.capytal.cc:80".extraConfig = ''
    header {
      X-Content-Type-Options "nosniff"
      X-Robots-Tag "noindex,nofollow"
      X-Permitted-Cross-Domain-Policies "none"
      Referrer-Policy "no-referrer"
      Strict-Transport-Security "max-age=15552000"
    }

    reverse_proxy http://10.0.2.2:80 {
      header_up X-Real-IP {header.Cf-Connecting-Ip}
      header_up X-Forwarded-Host {host}
      header_up X-Forwarded-For {header.Cf-Connecting-Ip}
      header_up X-Forwarded-Proto https
      header_up X-Http-Version {http.request.proto}
      header_up Host {host}
    }
  '';
  services.caddy.logFormat = ''
    level DEBUG
  '';
  services.caddy.globalConfig = ''
    auto_https disable_redirects

    # servers {
    #   protocols h1 h2 h2c
    #   listener_wrappers {
    #     layer4 {
    #       @turn tls talk.capytal.cc
    #       route @turn {
    #         proxy 10.0.2.2:3478
    #       }
    #     }
    #   }
    # }

    layer4 {
      tcp/:80 {
        @cpy tls sni turn.capytal.cc
        route @cpy {
          proxy tcp/10.0.2.2:3478
        }
      }
      tcp/:443 {
        @cpy-tls tls sni turn.capytal.cc
        route @cpy-tls {
          proxy tcp/10.0.2.2:3478
        }
      }
      udp/:80 {
        @cpy tls sni turn.capytal.cc
        route @cpy {
          proxy udp/10.0.2.2:3478
        }
      }
      udp/:443 {
        @cpy-tls tls sni turn.capytal.cc
        route @cpy-tls {
          proxy udp/10.0.2.2:3478
        }
      }
    }
  '';

  containers.nextcloud-cpy.autoStart = true;
  containers.nextcloud-cpy.privateNetwork = true;
  containers.nextcloud-cpy.privateUsers = "pick";
  containers.nextcloud-cpy.hostAddress = "192.168.0.101";
  containers.nextcloud-cpy.localAddress = "10.0.2.2";
  containers.nextcloud-cpy.extraFlags = [
    "--property=MemoryMax=1G"
    "--property=CPUQuota=100%" # One core
  ];
  containers.nextcloud-cpy.config = {
    config,
    pkgs,
    lib,
    ...
  }: let
    version = "35";
  in
    with lib; {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      services.nextcloud.enable = true;
      services.nextcloud.package = pkgs."nextcloud${version}";
      services.nextcloud.hostName = "cloud.capytal.cc";
      services.nextcloud.database.createLocally = true;
      services.nextcloud.configureRedis = true;
      services.nextcloud.extraAppsEnable = true;
      services.nextcloud.extraApps = {
        inherit
          (pkgs."nextcloud${version}Packages".apps)
          # mail
          calendar
          collectives
          contacts
          groupfolders
          news
          notes
          oidc_login
          spreed
          ;
        external = pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/external/releases/download/v10.0.0/external-v10.0.0.tar.gz";
          hash = "sha256-kI9etttV1PM2Z09bWmTubUcMsp05Iy3eG0iNveuZdic=";
          license = "agpl3Only";
        };
      };
      services.nextcloud.config = {
        adminuser = "capytal-admin";
        # HACK: On the nextcloud module definition, this is passed as is to LoadCredentials in systemd
        # service of nextcloud-setup. So we can just put the keyname defined by --load-credential
        adminpassFile =
          config.sops.secrets."containers/nextcloud-capytal/adminpass".path;

        dbtype = "pgsql";

        objectstore.s3 = {
          enable = true;
          bucket = "nextcloud-capytal";
          hostname = "s3.garage.local";
          usePathStyle = true;
          useSsl = false;
          region = "garage";
          key = "GK7fd378e9d89088ce0d6c0eb9";
          secretFile =
            config.sops.secrets."containers/nextcloud-capytal/s3-secret".path;
          verify_bucket_exists = true;
        };
      };
      services.nextcloud.secretFile =
        config.sops.secrets."containers/nextcloud-capytal/config".path;
      services.nextcloud.settings = {
        allow_user_to_change_display_name = false;
        lost_password_link = "disabled";
        "auth.authtoken.v1.disabled" = true;
        debug = false;
        default_language = "pt_BR";
        default_locale = "pt_BR";
        default_phone_region = "BR";
        default_timezone = hostCfg.time.timeZone;
        enforce_theme = "dark";
        loglevel = 1;
        maintenance_window_start = 5; # 2:00 AM at UTC-3
        trusted_proxies = ["192.168.0.101" "10.0.2.2" "127.0.0.1" "::1"];
        trusted_domains = [
          config.services.nextcloud.hostName
        ];
        overwriteprotocol = "https";

        oidc_login_provider_url = "https://auth.capytal.cc";
        # oidc_login_client_id = "via secret file"
        # oidc_login_client_secret = "via secret file"
        oidc_login_auto_redirect = true;
        oidc_login_end_session_redirect = false;
        oidc_login_button_text = "Log in with Capytal Account";
        oidc_login_hide_password_form = true;
        oidc_login_use_id_token = false;
        oidc_login_default_group = "oidc";
        oidc_login_use_external_storage = false;
        oidc_login_proxy_ldap = false;
        oidc_login_disable_registration = false;
        oidc_login_redir_fallback = false;
        oidc_login_tls_verify = true;
        oidc_create_groups = true;
        oidc_login_webdav_enabled = false;
        oidc_login_password_authentication = false;
        oidc_login_public_key_caching_time = 86400;
        oidc_login_min_time_between_jwks_requests = 10;
        oidc_login_well_known_caching_time = 86400;
        oidc_login_update_avatar = false;
        oidc_login_code_challenge_method = "S256";
      };
      services.nextcloud.phpExtraExtensions = all: with all; [opcache];
      services.nextcloud.phpOptions = {
        "opcache.interned_strings_buffer" = 50;
        "opcache.memory_consumption" = 128;
        "opcache.jit" = 1255;
        "opcache.jit_buffer_size" = "8M";
        "opcache.revalidate_freq" = 60;
        "opcache.save_comments" = 1;
      };

      services.nextcloud-spreed-signaling.enable = true;
      services.nextcloud-spreed-signaling.configureNginx = true;
      services.nextcloud-spreed-signaling.hostName = "talk.capytal.cc";
      services.nextcloud-spreed-signaling.backends."nextcloud-cpy" = {
        secretFile = config.sops.secrets."containers/nextcloud-capytal/spreed-secret".path;
        urls = ["https://${config.services.nextcloud.hostName}"];
      };
      services.nextcloud-spreed-signaling.settings = {
        clients.internalsecretFile =
          config.sops.secrets."containers/nextcloud-capytal/spreed-client-secret".path;
        http.listen = "127.0.0.1:8080";
        sessions = {
          hashkeyFile = config.sops.secrets."containers/nextcloud-capytal/spreed-hashkey".path;
          blockkeyFile = config.sops.secrets."containers/nextcloud-capytal/spreed-blockkey".path;
        };
      };

      # services.coturn.enable = true;
      # services.coturn.realm = "turn.capytal.cc";
      # services.coturn.static-auth-secret-file =
      #   config.sops.secrets."containers/nextcloud-capytal/coturn-secret".path;
      # services.coturn.use-auth-secret = true;
      # services.coturn.extraConfig = ''
      #   fingerprint
      #   total-quote=0
      #   bps-capacity=0
      #   stale-nonce
      #   no-multicast-peers
      # '';

      systemd.services.nextcloud-extra-occ-commands = {
        path = [config.services.nextcloud.occ];
        script = ''
          echo "Configuring Nextcloud options ---------------------------------"

          echo "nextcloud-occ config:app:set files default_quota --value '10 GB'"
          nextcloud-occ config:app:set files default_quota --value '10 GB'

          echo "Theming Nextcloud ---------------------------------------------"

          echo "nextcloud-occ theming:config name 'Capytal Cloud'"
          nextcloud-occ theming:config name 'Capytal Cloud'

          echo "nextcloud-occ theming:config slogan 'A, hopefully safe, home for your art.'"
          nextcloud-occ theming:config slogan 'A, hopefully safe, home for your art.'

          echo "nextcloud-occ theming:config url 'https://${config.services.nextcloud.hostName}'"
          nextcloud-occ theming:config url 'https://${config.services.nextcloud.hostName}'

          echo "nextcloud-occ theming:config primary_color '#8855A8'"
          nextcloud-occ theming:config primary_color '#8855A8'

          echo "nextcloud-occ theming:config background"
          nextcloud-occ theming:config background ${pkgs.fetchurl {
            url = "https://unsplash.com/photos/3TOyzKHkShw/download?force=true&w=2400";
            hash = "sha256-ivlQszJWIERC7iSNSc2470i7Nh54+l4+rpy2LJMDY28=";
          }}
        '';
        # echo "Configuring Spreed app ----------------------------------------"
        #
        # echo "nextcloud-occ talk:signaling:add"
        # nextcloud-occ talk:signaling:add \
        #   'wss://${config.services.nextcloud-spreed-signaling.hostName}' \
        #   "$(cat "${config.sops.secrets."containers/nextcloud-capytal/spreed-secret".path}")"
        #
        # echo "nextcloud-occ config:app:set spreed stun_servers"
        # nextcloud-occ config:app:set spreed stun_servers --value='${toJSON [
        #   {
        #     url = "${config.services.coturn.realm}:443?transport=tcp";
        #   }
        # ]}'
        #
        # echo "nextcloud-occ config:app:set spreed turn_servers"
        # turn='${toJSON [
        #   {
        #     server = "${config.services.coturn.realm}:443";
        #     secret = "SECRET";
        #     protocols = "udp,tcp";
        #   }
        # ]}'
        # turn="''${turn/SECRET/$(cat "${config.sops.secrets."containers/nextcloud-capytal/spreed-secret".path}")}"
        # echo "$turn"
        # nextcloud-occ config:app:set spreed turn_servers --value=$turn
        after = ["nextcloud-setup.service"];
        wantedBy = ["multi-user.target"];
      };

      services.postgresqlBackup.enable = true;
      services.postgresqlBackup.backupAll = true;
      services.postgresqlBackup.compressionLevel = 9;
      services.postgresqlBackup.startAt = "*-*-* 02:00:00 ${hostCfg.time.timeZone}";
      services.postgresqlBackup.location = "/run/media/cryptstorage/postgresql-nextcloud-capytal-backups";

      sops.defaultSopsFile = hostCfg.sops.defaultSopsFile;
      sops.defaultSopsFormat = hostCfg.sops.defaultSopsFormat;
      sops.age.keyFile = "/run/key.txt";
      sops.secrets = {
        "containers/nextcloud-capytal/adminpass" = {owner = "nextcloud";};
        "containers/nextcloud-capytal/db-pass" = {owner = "nextcloud";};
        "containers/nextcloud-capytal/config" = {owner = "nextcloud";};
        "containers/nextcloud-capytal/s3-secret" = {owner = "nextcloud";};
        "containers/nextcloud-capytal/spreed-hashkey" = {
          owner = config.services.nextcloud-spreed-signaling.user;
        };
        "containers/nextcloud-capytal/spreed-blockkey" = {
          owner = config.services.nextcloud-spreed-signaling.user;
        };
        "containers/nextcloud-capytal/spreed-secret" = {
          owner = config.services.nextcloud-spreed-signaling.user;
        };
        "containers/nextcloud-capytal/spreed-client-secret" = {
          owner = config.services.nextcloud-spreed-signaling.user;
        };
        "containers/nextcloud-capytal/coturn-secret" = {
          owner = config.systemd.services.coturn.serviceConfig.User;
          key = "containers/nextcloud-capytal/spreed-client-secret";
        };
      };

      networking.firewall.allowedTCPPorts = [80 config.services.coturn.listening-port];
      networking.firewall.allowedUDPPorts = [80 config.services.coturn.listening-port];

      system.stateVersion = "26.05";
    };
  containers.nextcloud-cpy.bindMounts = {
    cryptstorage-postgresql-dumps = {
      hostPath = "/run/media/cryptstorage/postgresql-nextcloud-capytal-backups";
      mountPoint = "/run/media/cryptstorage/postgresql-nextcloud-capytal-backups";
      isReadOnly = false;
    };
    key-txt = {
      hostPath = hostCfg.sops.age.keyFile;
      mountPoint = "/run/key.txt";
      isReadOnly = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /run/media/cryptstorage/postgresql-nextcloud-capytal-backups 0775 root root"
  ];
}
