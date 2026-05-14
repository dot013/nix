{config, ...}: {
  services.matrix-continuwuity = {
    enable = true;
    settings = {
      global = {
        server_name = "capytal.cc";

        allow_registration = true;
        registration_token = "abaduh";

        allow_encryption = true;
        allow_federation = false;
        trusted_servers = ["matrix.org"];

        address = null;
        port = [9802];

        well_known = {
          client = "https://capytal.cc";
          server = "capytal.cc";

          support_role = "m.role.admin";
          support_email = "admin@capytal.cc";
          support_mxid = "@admin:capytal.cc";

          rtc_focus_server_urls = [
            {
              type = "livekit";
              livekit_service_url = "https://livekit.capytal.cc";
            }
          ];
        };
      };
    };
  };

  services.mautrix-discord = let
    cfg = config.services.mautrix-discord;
    continuwuity = config.services.matrix-continuwuity.settings.global;
  in {
    enable = true;
    settings = {
      homeserver = {
        address = "http://localhost:${toString
          (builtins.elemAt continuwuity.port 0)}";
        domain = continuwuity.server_name;
      };
      appservice = rec {
        address = "http://localhost:${toString port}";
        hostname = "0.0.0.0";
        port = 9402;

        database = {
          type = "sqlite3";
          uri = "file:${cfg.dataDir}/mautrix-discord.db?_txlock=immediate";
          max_open_conns = 20;
          max_idle_conns = 2;
          max_conn_idle_time = null;
          max_conn_lifetime = null;
        };
        id = "discord";
        bot = {
          username = "discord";
          displayname = "Discord bridge bot";
          avatar = "mxc://maunium.net/nIdEykemnwdisvHbpxflpDlC";
        };
        ephemeral_events = true;
        async_transactions = false;
      };
      bridge = {
        permissions = {
          "*" = "relay";
          "${continuwuity.server_name}" = "user";
          "${continuwuity.well_known.support_mxid}" = "admin";
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
          ${continuwuity.server_name} = continuwuity.server_name;
        };
        login_shared_secret_map = {
          ${continuwuity.server_name} = "$MAUTRIX_DISCORD_BRIDGE_LOGIN_SHARED_SECRET";
        };
        # direct_media = {
        #   enable = false;
        #   server_name = "discord-matrix.capytal.cc";
        # };
        encryption = {
          allow = true;
          default = true;

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
    environmentFile = config.sops.secrets."mautrix_discord/env_file".path;
  };

  services.mautrix-meta.instances."default" = let
    continuwuity = config.services.matrix-continuwuity.settings.global;
  in {
    enable = true;
    settings = {
      network = {
        max_initial_conversations = 10;
        mode = "instagram";
      };
      homeserver = {
        address = "http://localhost:${toString
          (builtins.elemAt continuwuity.port 0)}";
        domain = continuwuity.server_name;
      };
      appservice = rec {
        address = "http://localhost:${toString port}";
        hostname = "0.0.0.0";
        port = 9404;

        as_token = "$MAUTRIX_META_APPSERVICE_AS_TOKEN";
        hs_token = "$MAUTRIX_META_APPSERVICE_HS_TOKEN";

        id = "meta";
        bot = {
          username = "meta";
          displayname = "Meta bridge bot";
        };
      };
      bridge = {
        permissions = {
          "*" = "relay";
          "${continuwuity.server_name}" = "user";
          "${continuwuity.well_known.support_mxid}" = "admin";
        };
      };
      backfill.enabled = true;
      database = {
        type = "sqlite3-fk-wal";
        uri = "file:/var/lib/${config.services.mautrix-meta.instances."default".dataDir}/mautrix-meta.db?_txlock=immediate";
      };
      encryption = {
        allow = true;
        default = true;

        allow_key_sharing = true;

        pickle_key = "$ENCRYPTION_PICKLE_KEY";

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
    environmentFile = config.sops.secrets."mautrix_meta/env_file".path;
  };

  services.mautrix-whatsapp = let
    continuwuity = config.services.matrix-continuwuity.settings.global;
  in {
    enable = true;
    settings = {
      network = {
        max_initial_conversations = 10;
      };
      homeserver = {
        address = "http://localhost:${toString
          (builtins.elemAt continuwuity.port 0)}";
        domain = continuwuity.server_name;
      };
      appservice = rec {
        address = "http://localhost:${toString port}";
        hostname = "0.0.0.0";
        port = 9403;

        id = "whatsapp";
        bot = {
          username = "whatsapp";
          displayname = "WhatsApp bridge bot";
        };
      };
      bridge = {
        permissions = {
          "*" = "relay";
          "${continuwuity.server_name}" = "user";
          "${continuwuity.well_known.support_mxid}" = "admin";
        };
      };

      backfill.enabled = true;

      database = {
        type = "sqlite3-fk-wal";
        uri = "file:/var/lib/mautrix-whatsapp/mautrix-whatsapp.db?_txlock=immediate";
      };

      encryption = {
        allow = true;
        default = true;

        allow_key_sharing = true;

        pickle_key = "$ENCRYPTION_PICKLE_KEY";

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
    environmentFile = config.sops.secrets."mautrix_whatsapp/env_file".path;
  };

  services.caddy.virtualHosts = {
    ":${toString (config.services.capytalcc.web.port + 1)}".extraConfig = ''
      # Matrix configuration ---------------------------------------------------

      # Homeserver (Continuwuity)

      @continuwuity {
        path /_matrix /_matrix/*
        path /_conduwuit /_conduwuit/*
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
        toString (builtins.elemAt config.services.matrix-continuwuity.settings.global.port 0)
      } {
          header_up Host {upstream_hostport}
        }
      }

      # Site -------------------------------------------------------------------

      handle / {
        respond `Hello, world` 200
      }
      handle /* {
        respond "Not Found" 404
      }
    '';
  };

  services.livekit = {
    enable = true;
    settings = {
      port = 9410;
      bind_addresses = ["0.0.0.0"];
      rtc = {
        tcp_port = 9411;
        port_range_start = 50100;
        port_range_end = 50200;
        use_external_ip = true;
        enable_loopback_candidate = false;
      };
    };
    keyFile = config.sops.secrets."livekit/key_file".path;
  };

  services.lk-jwt-service = {
    enable = true;
    port = 9412;
    keyFile = config.sops.secrets."livekit/key_file".path;
    livekitUrl = "wss://livekit.capytal.cc";
  };

  nixpkgs.config.permittedInsecurePackages = ["olm-3.2.16"];
}
