{
  config,
  lib,
  pkgs-unstable,
  self,
  ...
}:
with lib; let
  cfg = config.services.matrix-continuwuity;
  cfg-discord = config.services.mautrix-discord;
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

    oauth.compatibility_mode = "hybrid";
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
  systemd.services.continuwuity.serviceConfig.DynamicUser = mkForce false;

  services.mautrix-discord.enable = true;
  services.mautrix-discord.settings = {
    homeserver.address = "http://localhost:${toString (builtins.elemAt cfg.settings.global.port 0)}";
    homeserver.domain = cfg.settings.global.server_name;
    appservice = {
      address = "http://localhost:${toString cfg-discord.settings.appservice.port}";
      hostname = "0.0.0.0";
      port = 29334;
      database = {
        type = "postgres";
        uri = "postgres://mautrix-discord@localhost:${toString config.services.postgresql.settings.port}/mautrix-discord?sslmode=disable";
        max_open_conns = 20;
        max_idle_conns = 2;
        max_conn_idle_time = null;
        max_conn_lifetime = null;
      };
      id = "discord";
      bot = {
        username = "discordbot";
        displayname = "Discord bridge bot";
        avatar = "mxc://maunium.net/nIdEykemnwdisvHbpxflpDlC";
      };
      ephemeral_events = true;
      async_transactions = false;
    };
    bridge = {
      permissions = {
        "*" = "relay";
        "${cfg.settings.global.server_name}" = "user";
        "${cfg.settings.global.well_known.support_mxid}" = "admin";
      };
      backfill = {
        forward_limits.initial.dm = 50;
        forward_limits.initial.channel = 50;
        forward_limits.initial.thread = 50;

        forward_limits.missed.dm = -1;
        forward_limits.missed.channel = 1000;
        forward_limits.missed.thread = 1000;
      };
      start_private_channel_create_limit = 10;
      double_puppet_server_map = {
        ${cfg.settings.global.server_name} = cfg.settings.global.server_name;
      };
      login_shared_secret_map = {
        ${cfg.settings.global.server_name} = "$MAUTRIX_DISCORD_BRIDGE_LOGIN_SHARED_SECRET";
      };
      public_address = "https://capytal.cc";
      use_bot = true;
      enable_webhook_avatars = true;
      encryption = {
        allow = true;
        default = true;

        msc4190 = true;
        allow_key_sharing = true;

        delete_keys = {
          # https://docs.mau.fi/bridges/general/end-to-bridge-encryption.html#additional-security
          delete_outbound_on_ack = false;
          dont_store_outbound = true;
          ratchet_on_decrypt = true;
          delete_fully_used_on_decrypt = true;
          delete_prev_on_new_session = true;
          delete_on_device_delete = true;
          periodically_delete_expired = true;
          delete_outdated_inbound = true;
        };
      };
    };
  };
  services.mautrix-discord.environmentFile = config.sops.secrets."services/mautrix-discord/environment".path;

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

      @mautrix-discord {
        path /mautrix-discord /mautrix-discord/*
      }

      handle @mautrix-discord {
        header {
          Strict-Transport-Security "max-age=63072000;"
          X-Frame-Options "DENY"
          X-Content-Type-Options "nosniff"
          Referrer-Policy "no-referrer"
          Permissions-Policy "interest-cohort=()"
        }

        reverse_proxy http://localhost:${toString cfg-discord.settings.appservice.port} {
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

    "services/mautrix-discord/environment" = {owner = "mautrix-discord";};
  };

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
}
