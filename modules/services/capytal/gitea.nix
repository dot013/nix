{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.gitea;
in {
  services.gitea = {
    enable = true;
    package = inputs.loreddev-gitea.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = let
      initList = l: (concatStringsSep "," l);
    in rec {
      DEFAULT = {
        APP_NAME = "Capytal Code";
      };
      repository = {
        DEFAULT_REPO_UNITS = initList [
          "repo.code"
          "repo.issues"
          "repo.pulls"
        ];
        DEFAULT_TEMPLATE_REPO_UNITS = repository.DEFAULT_REPO_UNITS;
      };
      "repository.pull-request" = {
        CLOSE_KEYWORDS = initList [
          # en-US
          "close"
          "closes"
          "closed"
          "fix"
          "fixes"
          "fixed"
          "resolve"
          "resolves"
          "resolved"
          # pt-BR
          "corrige"
          "completa"
          "fecha"
          "implementa"
          "resolve"
          "termina"
        ];
      };
      "repository.signing" = {
        DEFAULT_TRUST_MODEL = "committer";
      };
      "ui.meta" = {
        AUTHOR = "Capytal";
        DESCRIPTION = replaceString "\n" " " ''
          Software forge dedicated for hosting official projects from Capytal and it's members.
          Explore and discover the source-code of our commercial user-facing products, internal
          developer-focused libraries, and infraestructure setups.
        '';
        KEYWORDS = initList [
          "capytal"
          "capytal code"
          "capytal-code"
          "git"
          "gitea"
          "projects"
          "development"
          "open source"
          "open-source"
        ];
      };
      server = {
        DOMAIN = "code.capytal.cc";
        ROOT_URL = "https://${server.DOMAIN}";
        PUBLIC_URL_DETECTION = "auto";
        HTTP_PORT = 9965;
        LFS_START_SERVER = true;
        LFS_JWT_SECRET = mkForce "";
        LFS_JWT_SECRET_URI = "file:${config.sops.secrets."services/gitea/lfs-jwt-secret".path}";
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
      database = {
        DB_TYPE = "sqlite3";
        NAME = "gitea";
        USER = "gitea";
        SQLITE_JOURNAL_MODE = "WAL";
      };
      security = {
        INTERNAL_TOKEN = mkForce "";
        INTERNAL_TOKEN_URI = "file:${config.sops.secrets."services/gitea/internal-token".path}";
        INSTALL_LOCK = true;
        COOKIE_REMEMBER_NAME = "__Host-capytal_code_forge_incredible";
        PASSWORD_COMPLEXITY = initList ["lower" "upper" "digit" "spec"];
        PASSWORD_CHECK_PWN = true;
        TWO_FACTOR_AUTH = "";
        SECRET_KEY = mkForce "";
        SECRET_KEY_URI = "file:${config.sops.secrets."services/gitea/secret-key".path}";
      };
      qos = {
        ENABLED = true; # For endpoints not protected by Anubis and protect from overload in general.
      };
      cache = {
        ADAPTER = "twoqueue";
        HOST = builtins.toJSON {
          size = 1000;
          recent_ratio = 0.25;
          ghost_ratio = 0.5;
        };
      };
      session = {
        COOKIE_SECURE = true;
        COOKIE_NAME = "__Host-i_like_capytal_code_forge";
        SAME_SITE = "strict";
      };
      picture = {
        DISABLE_GRAVATAR = true; # Deprecated
        ENABLE_FEDERATED_AVATAR = false; # Deprecated
      };
      "cron.delete_repo_archives" = {
        ENABLED = true;
      };
      "cron.git_gc_repos" = {
        ENABLED = true;
      };
      oauth2 = {
        ENABLED = true;
        JWT_SECRET = mkForce "";
        JWT_SECRET_URI = "file:${config.sops.secrets."services/gitea/jwt-secret".path}";
      };
      openid = {
        ENABLE_OPENID_SIGNIN = true;
        WHITELISTED_URIS = initList ["auth.capytal.cc"];
      };
      federation = {
        ENABLED = true;
      };
      attachment = {
        ENABLED = true;
        ALLOWED_TYPES = initList [
          ".avif"
          ".bbmodel"
          ".cpuprofile"
          ".csv"
          ".dmp"
          ".docx"
          ".fodg"
          ".fodp"
          ".fods"
          ".fodt"
          ".gif"
          ".gz"
          ".jpeg"
          ".jpg"
          ".json"
          ".jsonc"
          ".log"
          ".md"
          ".mov"
          ".mp4"
          ".odf"
          ".odg"
          ".odp"
          ".ods"
          ".odt"
          ".patch"
          ".pdf"
          ".png"
          ".pptx"
          ".svg"
          ".tgz"
          ".txt"
          ".webm"
          ".webp"
          ".xls"
          ".xlsx"
          ".zip"
        ];
      };
      lfs = {};
      storage = {
        STORAGE_TYPE = "minio";
        MINIO_USE_SSL = true;
        MINIO_INSECURE_SKIP_VERIFY = true;
        MINIO_ENDPOINT = "s3.garage.local";
        MINIO_BUCKET = "gitea";
        MINIO_LOCATION = config.services.garage.settings.s3_api.s3_region;
        MINIO_BUCKET_LOOKUP_TYPE = "path";
      };
      "storage.repo-archive" = {};
      "repo-archive" = {};
      # actions = {
      #   ENABLE = true;
      #   DEFAULT_ACTIONS_URL = "self";
      # };
    };
    minioAccessKeyId = config.sops.secrets."services/gitea/minio-access-key-id".path;
    minioSecretAccessKey = config.sops.secrets."services/gitea/minio-secret-access-key".path;
  };

  services.gitea-actions-runner.instances = let
    labels = [
      "nix-latest:docker://code.capytal.cc/dot013/nix-runner:latest"
      "godot-latest:docker://barichello/godot-ci:4.7.1"
    ];
    settings = {
      cache.enabled = true;
      cache.host = "battleship";
      cache.port = cfg.settings.server.HTTP_PORT + 100;
    };
    tokenFile = config.sops.secrets."services/gitea/actions-token".path;
    url = cfg.settings.server.ROOT_URL;
  in {
    "gitea-runner" = {
      enable = true;
      name = "Gitea Runner (${config.networking.hostName}) 1";
      inherit labels settings tokenFile url;
    };
    "gitea-runner-2" = {
      enable = true;
      name = "Gitea Runner (${config.networking.hostName}) 2";
      inherit labels settings tokenFile url;
    };
    "gitea-runner-3" = {
      enable = true;
      name = "Gitea Runner (${config.networking.hostName}) 2";
      inherit labels settings tokenFile url;
    };
    "gitea-runner-4" = {
      enable = true;
      name = "Gitea Runner (${config.networking.hostName}) 2";
      inherit labels settings tokenFile url;
    };
  };

  services.gitea.dump = {
    enable = true;
    type = "tar.xz";
    file = "gitea-dump.tar.xz";
    backupDir = "/run/media/cryptstorage/gitea/dumps";
    interval = "Sat *-*-* 04:00:00 ${config.time.timeZone}";
  };

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.containers.containersConf.settings = {
    network = {
      dns_bind_port = 1053;
    };
  };

  services.anubis.instances."gitea" = {
    policy = {
      useDefaultBotRules = true;
      extraBots = [
        {import = "(data)/apps/gitea-rss-feeds.yaml";}
        {import = "(data)/clients/git.yaml";}
        {import = "(data)/clients/go-get.yaml";}
        {import = "(data)/common/keep-internet-working.yaml";}
        {
          name = "discord-webhook-avatars";
          action = "ALLOW";
          expression = {
            all = [
              ''userAgent.contains("Discordbot")''
              ''path.startsWith("/avatars/")''
            ];
          };
        }
      ];
    };
    settings = {
      BIND = ":${toString (cfg.settings.server.HTTP_PORT + 2)}";
      BIND_NETWORK = "tcp";
      METRICS_BIND = ":${toString (cfg.settings.server.HTTP_PORT + 3)}";
      METRICS_BIND_NETWORK = "tcp";
      SERVE_ROBOTS_TXT = true;
      TARGET = "http://localhost:${toString cfg.settings.server.HTTP_PORT}";
      ED25519_PRIVATE_KEY_HEX_FILE = config.sops.secrets."services/anubis/gitea-private-key".path;
    };
  };

  services.caddy.virtualHosts = {
    "${cfg.settings.server.DOMAIN}:80".extraConfig = ''
      log {
        level DEBUG
      }
      header {
        X-Frame-Options "SAMEORIGIN"
        X-Content-Type-Options "nosniff"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
        Content-Security-Policy "${
        join "; " [
          "default-src 'self'"
          "worker-src 'self' blob: data:"
          "script-src 'self' 'unsafe-inline'"
          "style-src 'self' 'unsafe-inline'"
          "img-src 'self' https: data:"
          "font-src 'self' data:"
          "upgrade-insecure-requests"
          "report-to csp-endpoint"
        ]
      }"
        Cross-Origin-Opener-Policy "same-origin"
        Cross-Origin-Resource-Policy "cross-origin"
        Cross-Origin-Embedder-Policy "credentialless"
        Permissions-Policy "${join ", " ([
          "cross-origin-isolated=(\\\"https://code.capytal.cc\\\")"
          "encrypted-media=(\\\"https://code.capytal.cc\\\")"
          "picture-in-picture=(\\\"https://code.capytal.cc\\\")"
        ]
        ++ (map (d: "${d}=()") [
          "accelerometer"
          "ambient-light-sensor"
          "attribution-reporting"
          "bluetooth"
          "browsing-topics"
          "camera"
          "captured-surface-control"
          "ch-ua-high-entropy-values"
          "compute-pressure"
          "cross-origin-isolated"
          "deferred-fetch"
          "display-captured"
          "fullscreen"
          "gamepad"
          "geolocation"
          "gyroscope"
          "hid"
          "identity-credentials-get"
          "idle-detection"
          "language-detector"
          "language-model"
          "local-fonts"
          "local-network"
          "local-network-access"
          "magnetometer"
          "microphone"
          "midi"
          "on-device-speech-recognition"
          "otp-credentials"
          "payment"
          "private-state-token-issuance"
          "private-state-token-redemption"
          "publickey-credentials-create"
          "publickey-credentials-get"
          "screen-wake-lock"
          "serial"
          "speaker-selection"
          "storage-access"
          "translator"
          "summarizer"
          "usb"
          "web-share"
          "window-management"
          "xr-spatial-tracking"
        ]))}"
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"

        -Server
      }

      reverse_proxy http://localhost:${toString (cfg.settings.server.HTTP_PORT + 2)} {
        # header_up X-Real-Ip {header.Cf-Connecting-Ip}
        # header_up X-Forwarded-For {header.Cf-Connecting-Ip}
        header_up X-Forwarded-Proto https
        header_up X-Http-Version {http.request.proto}
        header_up Host {host}
      }
    '';
    "gitea.local".extraConfig = ''
      reverse_proxy http://localhost:${toString (cfg.settings.server.HTTP_PORT)}
    '';
    "forge.capytal.cc:80".extraConfig = ''
      redir https://code.capytal.cc permanent
    '';
    "forge.capytal.company:80".extraConfig = ''
      redir https://code.capytal.cc permanent
    '';
  };

  environment.persistence."/persist".directories = [
    {
      directory = cfg.repositoryRoot;
      user = cfg.user;
      group = cfg.group;
    }
    {
      directory = cfg.stateDir;
      user = cfg.user;
      group = cfg.group;
    }
  ];

  sops.secrets = {
    "services/gitea/actions-token" = {owner = cfg.user;};
    "services/gitea/internal-token" = {owner = cfg.user;};
    "services/gitea/jwt-secret" = {owner = cfg.user;};
    "services/gitea/lfs-jwt-secret" = {owner = cfg.user;};
    "services/gitea/minio-access-key-id" = {owner = cfg.user;};
    "services/gitea/minio-secret-access-key" = {owner = cfg.user;};
    "services/gitea/secret-key" = {owner = cfg.user;};
    # Anubis
    "services/anubis/gitea-private-key" = {owner = config.services.anubis.instances."gitea".user;};
  };
}
