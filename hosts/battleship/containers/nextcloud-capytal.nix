{
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
      X-Frame-Options "sameorigin"
      X-Permitted-Cross-Domain-Policies "none"
      Referrer-Policy "no-referrer"
      Strict-Transport-Security "max-age=15552000"
    }

    rewrite /.well-known/carddav /remote.php/dav{uri}
    rewrite /.well-known/caldav /remote.php/dav{uri}
    rewrite /.well-known/host-meta /public.php?service=host-meta-json
    rewrite /.well-known/host-meta.json /public.php?service=host-meta-json

    reverse_proxy http://10.0.2.2:80 {
      header_up X-Real-IP {header.Cf-Connecting-Ip}
      header_up X-Forwarded-Host {host}
      header_up X-Forwarded-For {header.Cf-Connecting-Ip}
      header_up X-Forwarded-Proto https
      header_up X-Http-Version {http.request.proto}
      header_up Host {host}
    }
  '';
    }
    handle {
      reverse_proxy http://localhost:2280 {
        header_up X-Real-IP {header.Cf-Connecting-Ip}
        header_up X-Forwarded-For {header.Cf-Connecting-Ip}
        header_up X-Forwarded-Proto https
        header_up X-Http-Version {http.request.proto}
        header_up Host {host}
      }
    }
  '';

  containers.nextcloud-cpy.autoStart = true;
  containers.nextcloud-cpy.privateNetwork = true;
  containers.nextcloud-cpy.privateUsers = "pick";
  containers.nextcloud-cpy.hostAddress = "192.168.0.101";
  containers.nextcloud-cpy.localAddress = "10.0.2.2";
  containers.nextcloud-cpy.extraFlags = [
    "--load-credential=adminpass:${config.sops.secrets."containers/nextcloud-capytal/adminpass".path}"
    "--load-credential=db-pass:${config.sops.secrets."containers/nextcloud-capytal/db-pass".path}"
    "--load-credential=config:${config.sops.secrets."containers/nextcloud-capytal/config".path}"
    "--load-credential=s3-secret:${config.sops.secrets."containers/nextcloud-capytal/s3-secret".path}"
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
      services.nextcloud.enable = true;
      services.nextcloud.package = pkgs."nextcloud${version}";
      services.nextcloud.hostName = "cloud.capytal.cc";
      services.nextcloud.database.createLocally = true;
      services.nextcloud.configureRedis = true;
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
        adminpassFile = "adminpass";

        dbtype = "pgsql";

        objectstore.s3 = {
          enable = true;
          bucket = "nextcloud-capytal";
          hostname = "s3.garage.local";
          usePathStyle = true;
          useSsl = false;
          region = "garage";
          key = "GK7fd378e9d89088ce0d6c0eb9";
          secretFile = "s3-secret";
          verify_bucket_exists = true;
        };
      };
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
        trusted_proxies = ["192.168.0.101"];
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
      services.nextcloud.secretFile = "config";

      systemd.services."nextcloud-setup" = {
        wants = ["network-online.target"];
        after = ["network-online.target"];
      };

      systemd.services.nextcloud-extra-occ-commands = {
        path = [config.services.nextcloud.occ];
        script = ''
          nextcloud-occ config:app:set files default_quota --value '10 GB'

          nextcloud-occ theming:config name 'Capytal Cloud'
          nextcloud-occ theming:config slogan 'A, hopefully safe, home for your art.'
          nextcloud-occ theming:config url 'https://${config.services.nextcloud.hostName}'
          nextcloud-occ theming:config primary_color '#8855A8'
          nextcloud-occ theming:config background ${pkgs.fetchurl {
            url = "https://unsplash.com/photos/3TOyzKHkShw/download?force=true&w=2400";
            hash = "sha256-ivlQszJWIERC7iSNSc2470i7Nh54+l4+rpy2LJMDY28=";
          }}
          nextcloud-occ theming:config logo '${pkgs.fetchurl {
            url = "https://code.capytal.cc/capytal/capytal/raw/branch/main/brand/png/logo-light-transparent.png";
            hash = "sha256-9IckrsaloLGHVWOAG/2EraZzV78snrIDVZnvnSpa9kk=";
          }}'
          nextcloud-occ theming:config logoheader '${pkgs.fetchurl {
            url = "https://code.capytal.cc/capytal/capytal/raw/branch/main/brand/png/logo-light-asset.png";
            hash = "sha256-W5d7uzFIG7pZneBcGP1MCFQBzgYow2TseTMrvV1TGxk=";
          }}'
        '';
        after = ["nextcloud-setup.service"];
        wantedBy = ["multi-user.target"];
      };

      services.postgresqlBackup.enable = true;
      services.postgresqlBackup.backupAll = true;
      services.postgresqlBackup.compressionLevel = 9;
      services.postgresqlBackup.startAt = "*-*-* 02:00:00 ${hostCfg.time.timeZone}";
      services.postgresqlBackup.location = "/run/media/cryptstorage/postgresql-nextcloud-capytal-backups";

      networking.firewall.allowedTCPPorts = [80];
      networking.firewall.allowedUDPPorts = [80];

      system.stateVersion = "26.05";
    };
  containers.nextcloud-cpy.bindMounts = {
    cryptstorage-postgresql-dumps = {
      hostPath = "/run/media/cryptstorage/postgresql-nextcloud-capytal-backups";
      mountPoint = "/run/media/cryptstorage/postgresql-nextcloud-capytal-backups";
      isReadOnly = false;
    };
  };

  systemd.tmpfiles.rules = [
    "d /run/media/cryptstorage/postgresql-nextcloud-capytal-backups 0775 root root"
  ];

  sops.secrets = {
    "containers/nextcloud-capytal/adminpass" = {restartUnits = ["container@nextcloud-capytal.service"];};
    "containers/nextcloud-capytal/db-pass" = {restartUnits = ["container@nextcloud-capytal.service"];};
    "containers/nextcloud-capytal/config" = {restartUnits = ["container@nextcloud-capytal.service"];};
    "containers/nextcloud-capytal/s3-secret" = {restartUnits = ["container@nextcloud-capytal.service"];};
  };
}
