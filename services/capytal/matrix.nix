{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.services.matrix-continuwuity;
in {
  services.matrix-continuwuity.enable = true;
  services.matrix-continuwuity.package = pkgs-unstable.matrix-continuwuity;
  services.matrix-continuwuity.settings.global = {
    port = [6167];
    allow_encryption = true;
    allow_federation = false;
    allow_registration = false;
    server_name = "capytal.cc";
    new_user_displayname_suffx = "○";
    trusted_servers = ["matrix.org"];

    oauth.oidc = {
      discovery_url = "https://auth.capytal.cc";
      client_id = "capytal_continuwuity";
      client_secret_file = config.sops.secrets."services/continuwuity/oidc-client-secret".path;
      additional_scopes = ["email" "profile"];
    };

    well_known = {
      client = "https://capytal.cc";
      server = "capytal.cc";

      support_role = "m.role.admin";
      support_email = "contact@capytal.cc";
      support_mxid = "@admin:capytal.cc";

      # rtc_focus_server_urls = [
      #   {
      #     type = "livekit";
      #     livekit_service_url = "https://livekit.capytal.cc";
      #   }
      # ];
    };
  };

  services.caddy.virtualHosts = {
    "capytal.cc:80".extraConfig = ''
      @continuwuity {
        path /_matrix /_matrix/*
        path /_conduwuit /_conduwuit/*
        path /_continuwuity /_continuwuity/*
        path /.well-known/matrix /.well-known/matrix/*
      }

      handle @continuwuity {
        header {
          Strict-Transport-Security "max-age=63072000;"
          X-Frame-Options "DENY"
          X-Content-Type-Options "nosniff"
          Referrer-Policy "no-referrer"
          Permissions-Policy "interest-cohort=()"
        }

        reverse_proxy http://localhost:${
        toString (builtins.elemAt cfg.settings.global.port 0)
      } {
          header_up Host {upstream_hostport}
        }
      }
    '';
  };

  # services.livekit.enable = true;
  # services.livekit.settings = {
  #   port = (elemAt cfg.settings.global.port 0) + 5;
  #   rtc.tcp_port = config.services.livekit.port + 1;
  #   rtc.port_range_start = 50100;
  #   rtc.port_range_end = 50200;
  #   rtc.use_external_ip = true;
  #   rtc.enable_loopback_candidate = false;
  #   keyFile = config.sops.secrets."services/livekit/key-file".path;
  # };
  #
  # services.lk-jwt-service.enable = true;
  # services.lk-jwt-service.port = (elemAt cfg.settings.global.port 0) + 10;
  # services.lk-jwt-service.keyFile = config.sops.secrets."services/livekit/key-file".path;
  # services.lk-jwt-service.livekitUrl = "wss://livekit.capytal.cc";
  #
  sops.secrets = {
    "services/continuwuity/oidc-client-secret" = {owner = cfg.user;};

    # "services/livekit/key-file" = {};
  };
}
