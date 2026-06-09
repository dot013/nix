{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.services.gitea;
in {
  services.gitea = {
    enable = true;
    package = inputs.loreddev-gitea.packages.${pkgs.stdenv.hostPlatform.system}.default;
    # lfs.enable = true;
    settings = with lib; let
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
      };
      database = {
        DB_TYPE = "sqlite3";
        NAME = "gitea";
        USER = "gitea";
        SQLITE_JOURNAL_MODE = "WAL";
      };
      security = {
        INSTALL_LOCK = true;
        COOKIE_REMEMBER_NAME = "__Host-capytal_code_forge_incredible";
        PASSWORD_COMPLEXITY = initList ["lower" "upper" "digit" "spec"];
        PASSWORD_CHECK_PWN = true;
        TWO_FACTOR_AUTH = "";
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
      # lfs = {};
      # storage = {
      #   STORAGE_TYPE = "minio";
      #   MINIO_USE_SSL = false;
      #   MINIO_ENDPOINT = "localhost:3461";
      #   MINIO_BUCKET = "gitea";
      #   MINIO_LOCATION = config.services.garage.settings.s3_api.s3_region;
      # };
      "storage.repo-archive" = {};
      "repo-archive" = {};
      # actions = {
      #   ENABLE = true;
      #   DEFAULT_ACTIONS_URL = "self";
      # };
    };
  };

  systemd.services.gitea.serviceConfig = {
    EnvironmentFile = config.sops.secrets."services/gitea/env-file".path;
  };

  # services.gitea-actions-runner.instances = {
  #   "gitea-runner" = {
  #     enable = true;
  #     name = "Gitea Runner (${config.networking.hostName}) 1";
  #     url = cfg.settings.server.ROOT_URL;
  #     tokenFile = config.sops.secrets."gitea/actions/token".path;
  #     labels = ["nix-latest:docker://code.capytal.cc/images/nix:2.31.3"];
  #   };
  # };

  # services.anubis.instances."gitea".settings = {
  #   BIND = ":${toString (cfg.settings.server.HTTP_PORT + 2)}";
  #   BIND_NETWORK = "tcp";
  #   METRICS_BIND = ":${toString (cfg.settings.server.HTTP_PORT + 3)}";
  #   METRICS_BIND_NETWORK = "tcp";
  #   SERVE_ROBOTS_TXT = true;
  #   TARGET = "http://localhost:${toString cfg.settings.server.HTTP_PORT}";
  #   ED25519_PRIVATE_KEY_HEX_FILE = config.sops.secrets."anubis/gitea/hex_file".path;
  # };

  services.caddy.virtualHosts = {
    "${cfg.settings.server.DOMAIN}:80".extraConfig = ''
      header {
        X-Frame-Options "SAMEORIGIN"
        X-Content-Type-Options "nosniff"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
        Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' blob: data:; font-src 'self' data:; upgrade-insecure-requests; report-to csp-endpoint"
        -Server
      }

      reverse_proxy http://localhost:${toString cfg.settings.server.HTTP_PORT} {
        header_up X-Real-Ip {header.Cf-Connecting-Ip}
        header_up X-Forwarded-For {header.Cf-Connecting-Ip}
        header_up X-Forwarded-Proto https
        header_up Host {host}
      }
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
      directory = cfg.stateDir;
      user = cfg.user;
      group = cfg.group;
    }
  ];

  sops.secrets = {
    "services/gitea/actions-token" = {owner = cfg.user;};
    "services/gitea/env-file" = {owner = cfg.user;};
  };
}
