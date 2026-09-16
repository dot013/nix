{config, ...}: let
  cfg = config.services.peertube;
in {
  services.peertube = {
    enable = true;

    database.createLocally = true;
    redis.createLocally = true;

    enableWebHttps = false;
    localDomain = "creators.capytal.cc";
    listenWeb = 443;

    serviceEnvironmentFile = config.sops.secrets."services/peertube/environmentFile".path;
    secrets.secretsFile = config.sops.secrets."services/peertube/secretsFile".path;

    settings = {
      listen.hostname = "localhost";
      object_storage = {
        enabled = true;

        endpoint = "http://s3.garage.local";
        region = config.services.garage.settings.s3_api.s3_region;
        force_path_style = true;
        upload_acl.private = null;

        streaming_playlists.bucket_name = "peertube";
        streaming_playlists.prefix = "streaming-playlists/";
        web_videos.bucket_name = "peertube";
        web_videos.prefix = "web-videous/";
        user_exports.bucket_name = "peertube";
        user_exports.prefix = "user-exports/";
        original_video_files.bucket_name = "peertube";
        original_video_files.prefix = "original-video-files/";
        captions.bucket_name = "peertube";
        captions.prefix = "captions/";
      };

      log = {
        anonymize_ip = true;
      };

      csp = {
        enabled = true;
      };

      federation.enabled = false;
    };
  };

  services.caddy = {
    # Thanks to https://gist.github.com/toby3d/ad2f20f31d1c71a51914045efd0a9a61
    virtualHosts = {
      "${cfg.localDomain}:80".extraConfig = ''
        handle /api/v1/videos/upload-resumable {
          request_body max_size 0
          import api
        }

        @uploads {
          path_regexp ^/api/v1/videos/(upload|([^/]+/studio/edit))$
          not method POST HEAD
        }
        handle @uploads {
          request_body max_size 12GiB
          header X-File-Maximum-Size "8G always"
          import api
        }

        @videos path_regexp ^/api/v1/(videos|video-playlists|video-channels|users/me)
        handle @videos {
          request_body max_size 6MiB
          header X-File-Maximum-Size "4M always"
          import api
        }

        handle /socket.io {
          import api_websocket
        }
        handle /tracker/socket {
          import api_websocket
        }

        encode {
          match {
            header Content-Type "text/*" # text/html text/css
            header Content-Type "application/javascript*" # application/javascript
            header Content-Type "font/truetype*" # font/truetype
            header Content-Type "font/opentype*" # font/opentype
            header Content-Type "application/vnd.ms-fontobject*" # application/vnd.ms-fontobject
            header Content-Type "image/svg+xml*" # image/svg+xml
          }
          minimum_length 1000
          gzip 2
        }

        handle {
          import api
        }

        reverse_proxy :${toString cfg.listenHttp}
      '';
    };
    extraConfig = ''
      (api) {
        request_body max_size 100KiB
        reverse_proxy {
          header_up X-Real-IP {remote_host}
          transport http {
            dial_timeout 10m
          }
          to :${toString cfg.listenHttp}
        }
      }
      (api_websocket) {
        reverse_proxy {
          transport http {
            versions 1.1
          }
          header_up X-Real-IP {remote_host}
          header_up Upgrade websocket
          header_up Connection upgrade
          to :${toString cfg.listenHttp}
        }
      }
    '';
  };

  sops.secrets = {
    "services/peertube/environmentFile" = {owner = cfg.user;};
    "services/peertube/secretsFile" = {owner = cfg.user;};
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/peertube/config 0700 peertube peertube - -"
  ];
}
