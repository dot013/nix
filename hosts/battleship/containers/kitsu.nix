{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  services.caddy.virtualHosts."studio.capytal.cc:80".extraConfig = ''
    @redirect {
      expression `{http.response.status} in [301, 302, 303, 307, 308]`
    }
    header @redirect >Location "http://(.*)" "https://$1"

    reverse_proxy http://localhost:8080 {
      header_up X-Real-IP {header.Cf-Connecting-Ip}
      header_up X-Forwarded-Host {host}
      header_up X-Forwarded-For {header.Cf-Connecting-Ip}
      header_up X-Forwarded-Proto https
      header_up X-Http-Version {http.request.proto}
      header_up Host {host}
    }
  '';

  # Containers
  virtualisation.oci-containers.containers."kitsu-kitsu-web" = {
    image = "ghcr.io/ahmed-hindy/kitsu-web:v1.0.48@sha256:dd3a169adb7e6763284d4239b54f1c56ba5d8792cc13d4d23362669e25f60e22";
    environmentFiles = [
      config.sops.secrets."containers/kitsu/env".path
    ];
    environment = {"VITE_API_URL" = "/api";};
    dependsOn = ["kitsu-zou-api"];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=wget -q --spider http://127.0.0.1/"
      "--health-interval=10s"
      "--health-retries=20"
      "--health-timeout=5s"
      "--network-alias=kitsu-web"
      "--network=kitsu_internal"
      "--network=kitsu_web"
    ];
  };
  systemd.services."podman-kitsu-kitsu-web" = {
    serviceConfig = {Restart = lib.mkOverride 90 "always";};
    after = ["podman-network-kitsu_internal.service" "podman-network-kitsu_web.service"];
    requires = ["podman-network-kitsu_internal.service" "podman-network-kitsu_web.service"];
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };

  virtualisation.oci-containers.containers."kitsu-mailcatcher" = {
    image = "schickling/mailcatcher:latest@sha256:55ed289525a565f7587b138a423705267eb34eda1ec8d35acd6dc7966a933e84";
    ports = [
      "1080:1080/tcp"
      "1025:1025/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=mailcatcher"
      "--network=kitsu_internal"
    ];
  };
  systemd.services."podman-kitsu-mailcatcher" = {
    serviceConfig = {Restart = lib.mkOverride 90 "no";};
    after = ["podman-network-kitsu_internal.service"];
    requires = ["podman-network-kitsu_internal.service"];
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };

  virtualisation.oci-containers.containers."kitsu-meilisearch" = {
    image = "getmeili/meilisearch:v1.11.3@sha256:6f8f1fc29d1ff67b4d8d503bb4e0a69b55c8d42600decafde951344218193a27";
    environment = {
      "MEILI_MASTER_KEY" = "very_secret_meili_key";
      "MEILI_NO_ANALYTICS" = "true";
    };
    volumes = [
      "kitsu_meili:/meili_data:rw"
    ];
    environmentFiles = [
      config.sops.secrets."containers/kitsu/env".path
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=wget -qO- http://127.0.0.1:\${MEILI_PORT:-7700}/health | grep -q available"
      "--health-interval=10s"
      "--health-retries=20"
      "--health-timeout=5s"
      "--network-alias=meilisearch"
      "--network=kitsu_internal"
    ];
  };
  systemd.services."podman-kitsu-meilisearch" = {
    serviceConfig = {Restart = lib.mkOverride 90 "always";};
    after = ["podman-network-kitsu_internal.service" "podman-volume-kitsu_meili.service"];
    requires = ["podman-network-kitsu_internal.service" "podman-volume-kitsu_meili.service"];
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };

  virtualisation.oci-containers.containers."kitsu-nginx" = {
    image = "nginx:alpine@sha256:713fc2ebfd92e8217db451477182ee91944b123d2b1ee9fd5a8c6e91ca6c3a11";
    volumes = [
      "${pkgs.fetchurl {
        url = "https://github.com/Ahmed-Hindy/Kitsu-Docker-Prod/raw/40ad68ec8de118d72c2a1b67812a5627b3229798/nginx.conf";
        hash = "sha256-Ut7EhzFbFit6JfUiAQSwx+HufdkZXbmUVlTC33K4kek=";
      }}:/etc/nginx/conf.d/default.conf:ro"
    ];
    ports = ["8080:80/tcp"];
    environmentFiles = [
      config.sops.secrets."containers/kitsu/env".path
    ];
    labels = {
      "traefik.docker.network" = "kitsu_web";
      "traefik.enable" = "true";
      "traefik.http.routers.kitsu-http.entrypoints" = "web";
      "traefik.http.routers.kitsu-http.rule" = "Host(`192.168.1.5`)";
      "traefik.http.routers.kitsu-http.service" = "kitsu";
      "traefik.http.routers.kitsu-https.entrypoints" = "websecure";
      "traefik.http.routers.kitsu-https.rule" = "Host(`192.168.1.5`)";
      "traefik.http.routers.kitsu-https.service" = "kitsu";
      "traefik.http.routers.kitsu-https.tls" = "true";
      "traefik.http.routers.kitsu-https.tls.certresolver" = "letsencrypt";
      "traefik.http.services.kitsu.loadbalancer.server.port" = "80";
    };
    dependsOn = [
      "kitsu-kitsu-web"
      "kitsu-zou-api"
      "kitsu-zou-events"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=wget -q --spider http://127.0.0.1/"
      "--health-interval=10s"
      "--health-retries=20"
      "--health-timeout=5s"
      "--network-alias=nginx"
      "--network=kitsu_internal"
      "--network=kitsu_web"
    ];
  };
  systemd.services."podman-kitsu-nginx" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    unitConfig.Description = "Container kitsu-nginx generated by compose2nix.";
    after = [
      "podman-network-kitsu_internal.service"
      "podman-network-kitsu_web.service"
    ];
    requires = [
      "podman-network-kitsu_internal.service"
      "podman-network-kitsu_web.service"
    ];
    partOf = [
      "podman-compose-kitsu-root.target"
    ];
    wantedBy = [
      "podman-compose-kitsu-root.target"
    ];
  };

  virtualisation.oci-containers.containers."kitsu-redis" = {
    image = "redis:7-alpine@sha256:c5d34a98396a4775e223c74e929162c35c5a2182901ba26b50ade939941ce14b";
    log-driver = "journald";
    environmentFiles = [
      config.sops.secrets."containers/kitsu/env".path
    ];
    extraOptions = [
      "--health-cmd=redis-cli -p \${REDIS_PORT:-6379} ping | grep -q PONG"
      "--health-interval=5s"
      "--health-retries=20"
      "--health-timeout=5s"
      "--network-alias=redis"
      "--network=kitsu_internal"
    ];
  };
  systemd.services."podman-kitsu-redis" = {
    serviceConfig = {Restart = lib.mkOverride 90 "always";};
    after = ["podman-network-kitsu_internal.service"];
    requires = ["podman-network-kitsu_internal.service"];
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };

  virtualisation.oci-containers.containers."kitsu-traefik" = {
    image = "traefik:v3.7.6@sha256:21a3d83696379bac6434bb32e1dde0aff0e84ef2abd053ed3db87d3f45e749b2";
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock:ro"
      "/var/lib/kitsu/traefik/letsencrypt:/letsencrypt:rw"
    ];
    environmentFiles = [
      config.sops.secrets."containers/kitsu/env".path
    ];
    ports = [
      "8081:80/tcp"
    ];
    cmd = [
      "--api.dashboard=false"
      "--providers.docker=true"
      "--providers.docker.exposedbydefault=false"
      "--entrypoints.web.address=:80"
      "--entrypoints.websecure.address=:443"
      "--certificatesresolvers.letsencrypt.acme.email=admin@example.com"
      "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
      "--log.level=INFO"
      "--accesslog=true"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=traefik"
      "--network=kitsu_web"
    ];
  };
  systemd.services."podman-kitsu-traefik" = {
    serviceConfig = {Restart = lib.mkOverride 90 "always";};
    after = ["podman-network-kitsu_web.service" "podman-volume-kitsu_traefik_letsencrypt.service"];
    requires = ["podman-network-kitsu_web.service" "podman-volume-kitsu_traefik_letsencrypt.service"];
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };

  virtualisation.oci-containers.containers."kitsu-zou-api" = {
    image = "ghcr.io/ahmed-hindy/kitsu-zou:v1.0.52@sha256:ee06e9f3455b46ffe4d943fefda1897b6da34b66e939bc39494c54525686d61a";
    environment = {
      "AYON_PORT" = "5000";
      "BACKUP_CRON" = "30 1 * * *";
      "BACKUP_RETENTION_DAYS" = "14";
      "COMPOSE_PROJECT_NAME" = "kitsu-docker-main";
      "CORS_ALLOWED_ORIGINS" = "https://studio.capytla.cc";
      "DEFAULT_LOCALE" = "pt_BR";
      "DEFAULT_TIMEZONE" = "America/Sao_Paulo";
      "DB_DATABASE" = "kitsu";
      "DB_HOST" = "${config.containers.postgresql.localAddress}";
      # "DB_PASSWORD" = "kitsu_pass";
      "DB_PORT" = "5432";
      "DB_TYPE" = "postgres";
      "DB_USERNAME" = "kitsu";
      "DOCKER_HOST_IP" = "192.168.1.5";
      "DOMAIN_NAME" = "studio.capytal.cc";
      "DOMAIN_PROTOCOL" = "http";
      "ENABLE_JOB_QUEUE" = "True";
      "INDEXER_HOST" = "meilisearch";
      # "INDEXER_KEY" = "very_secret_meili_key";
      "INDEXER_PORT" = "7700";
      "INDEXER_TYPE" = "meilisearch";
      "JOB_QUEUE_TIMEOUT" = "3600";
      "KITSU_DOMAIN" = "https://studio.capytal.cc";
      "KITSU_WEB_HOST" = "192.168.1.5";
      "KITSU_WEB_HOST_PORT" = "8080";
      "KITSU_WEB_URL" = "https://studio.capytal.cc";
      "KV_HOST" = "redis";
      "KV_PORT" = "6379";
      "KV_TYPE" = "redis";
      "LETSENCRYPT_EMAIL" = "admin@example.com";
      "LOG_LEVEL" = "info";
      "MAILCATCHER_HTTP_PORT" = "1080";
      "MAILCATCHER_SMTP_PORT" = "1025";
      "MAIL_DEFAULT_SENDER" = "kitsu@example.com";
      "MAIL_PORT" = "1025";
      "MAIL_SERVER" = "mailcatcher";
      "MAIL_USE_SSL" = "false";
      "MAIL_USE_TLS" = "false";
      "MEILI_MASTER_KEY" = "very_secret_meili_key";
      "MEILI_PORT" = "7700";
      "POSTGRES_DB" = "kitsu";
      # "POSTGRES_PASSWORD" = "kitsu_pass";
      "POSTGRES_USER" = "kitsu";
      "PREVIEW_BACKUP_RETENTION_DAYS" = "14";
      "PREVIEW_FOLDER" = "/opt/zou/previews";
      "REDIS_PORT" = "6379";
      "REDIS_URL" = "redis://redis:6379/0";
      # "SECRET_KEY" = "mysecretpassword";
      "TMP_DIR" = "/tmp/zou";
      "TRAEFIK_HTTPS_PORT" = "443";
      "TRAEFIK_HTTP_PORT" = "80";
      # "ZOU_ADMIN_EMAIL" = "admin@example.com";
      # "ZOU_ADMIN_PASSWORD" = "mysecretpassword";
      "ZOU_ALLOWED_HOSTS" = "*";
      "ZOU_API_HOST_PORT" = "5001";
      "ZOU_API_INTERNAL_PORT" = "8000";
      "ZOU_API_URL" = "https://studio.capytal.cc/api";
      "ZOU_EVENTS_INTERNAL_PORT" = "5001";
      "ZOU_LOG_LEVEL" = "info";
      # "ZOU_SECRET_KEY" = "mysecretpassword";
      "ZOU_THREADS" = "2";
      "ZOU_WORKERS" = "4";
      "OIDC_DISCOVERY_URL" = "https://auth.capytal.cc/.well-known/openid-configuration";

      "FS_BACKEND" = "s3";
      "FS_BUCKET_PREFIX" = "kitsu-";
      "FS_S3_REGION" = "garage";
      "FS_S3_ENDPOINT" = "http://s3.garage.local";
      "FS_S3_CREATE_BUCKET" = "False";
    };
    environmentFiles = [
      config.sops.secrets."containers/kitsu/env".path
    ];
    volumes = [
      "/var/lib/kitsu/previews:/opt/zou/previews:rw"
      "/var/lib/kitsu/zou/tmp:/tmp/zou:rw"
    ];
    ports = [
      "5001:8000/tcp"
    ];
    dependsOn = [
      # "kitsu-db"
      "kitsu-meilisearch"
      "kitsu-redis"
      "kitsu-zou-init-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=/opt/venv/bin/python -c 'import os, urllib.request; port = os.environ.get(\"ZOU_API_INTERNAL_PORT\", \"8000\"); response = urllib.request.urlopen(\"http://127.0.0.1:%s/\" % port, timeout=5); raise SystemExit(0 if response.status < 500 else 1)'"
      "--health-interval=10s"
      "--health-retries=30"
      "--health-start-period=20s"
      "--health-timeout=5s"
      "--network-alias=zou-api"
      "--network=kitsu_internal"
      "--add-host=db:host-gateway"
    ];
  };
  systemd.services."podman-kitsu-zou-api" = {
    serviceConfig = {Restart = lib.mkOverride 90 "always";};
    after = [
      "podman-network-kitsu_internal.service"
      "podman-volume-kitsu_previews.service"
      "podman-volume-kitsu_zou_tmp.service"
    ];
    requires = [
      "podman-network-kitsu_internal.service"
      "podman-volume-kitsu_previews.service"
      "podman-volume-kitsu_zou_tmp.service"
    ];
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };

  virtualisation.oci-containers.containers."kitsu-zou-events" = {
    image = "ghcr.io/ahmed-hindy/kitsu-zou:v1.0.52@sha256:ee06e9f3455b46ffe4d943fefda1897b6da34b66e939bc39494c54525686d61a";
    environment =
      config.virtualisation.oci-containers.containers."kitsu-zou-api".environment;
    environmentFiles =
      config.virtualisation.oci-containers.containers."kitsu-zou-api".environmentFiles;
    cmd = ["gunicorn" "--workers=1" "--worker-class=geventwebsocket.gunicorn.workers.GeventWebSocketWorker" "-b" "0.0.0.0:5001" "zou.event_stream:app"];
    dependsOn = [
      # "kitsu-db"
      "kitsu-meilisearch"
      "kitsu-redis"
      "kitsu-zou-init-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=/opt/venv/bin/python -c 'import os, socket; port = int(os.environ.get(\"ZOU_EVENTS_INTERNAL_PORT\", \"5001\")); socket.create_connection((\"127.0.0.1\", port), timeout=5).close()'"
      "--health-interval=10s"
      "--health-retries=30"
      "--health-start-period=20s"
      "--health-timeout=5s"
      "--network-alias=zou-events"
      "--network=kitsu_internal"
      "--add-host=db:host-gateway"
    ];
  };
  systemd.services."podman-kitsu-zou-events" = {
    serviceConfig = {Restart = lib.mkOverride 90 "always";};
    after = ["podman-network-kitsu_internal.service"];
    requires = ["podman-network-kitsu_internal.service"];
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };

  virtualisation.oci-containers.containers."kitsu-zou-init-db" = {
    image = "ghcr.io/ahmed-hindy/kitsu-zou:v1.0.52@sha256:ee06e9f3455b46ffe4d943fefda1897b6da34b66e939bc39494c54525686d61a";
    environment =
      config.virtualisation.oci-containers.containers."kitsu-zou-api".environment;
    environmentFiles =
      config.virtualisation.oci-containers.containers."kitsu-zou-api".environmentFiles;
    volumes = [
      "${pkgs.fetchurl {
        url = "https://github.com/Ahmed-Hindy/Kitsu-Docker-Prod/raw/40ad68ec8de118d72c2a1b67812a5627b3229798/zou/init-db.sh";
        hash = "sha256-oxSq3rohhhCFlHnbxebEuzbU+jFv1CR5k1WuSpYKtCo=";
      }}:/usr/local/bin/zou-init-db:ro"
      "/var/lib/kitsu/previews:/opt/zou/previews:rw"
      "/var/lib/kitsu/zou/tmp:/tmp/zou:rw"
    ];
    dependsOn = [
      # "kitsu-db"
      "kitsu-meilisearch"
      "kitsu-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--entrypoint=[\"sh\", \"/usr/local/bin/zou-init-db\"]"
      "--network-alias=zou-init-db"
      "--network=kitsu_internal"
      "--add-host=db:host-gateway"
    ];
  };
  systemd.services."podman-kitsu-zou-init-db" = {
    serviceConfig = {Restart = lib.mkOverride 90 "no";};
    after = [
      "podman-network-kitsu_internal.service"
      "podman-volume-kitsu_previews.service"
      "podman-volume-kitsu_zou_tmp.service"
    ];
    requires = [
      "podman-network-kitsu_internal.service"
      "podman-volume-kitsu_previews.service"
      "podman-volume-kitsu_zou_tmp.service"
    ];
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };

  virtualisation.oci-containers.containers."kitsu-zou-jobs" = {
    image = "ghcr.io/ahmed-hindy/kitsu-zou:v1.0.52@sha256:ee06e9f3455b46ffe4d943fefda1897b6da34b66e939bc39494c54525686d61a";
    environment =
      config.virtualisation.oci-containers.containers."kitsu-zou-api".environment;
    environmentFiles =
      config.virtualisation.oci-containers.containers."kitsu-zou-api".environmentFiles;
    volumes = [
      "/var/lib/kitsu/previews:/opt/zou/previews:rw"
      "/var/lib/kitsu/zou/tmp:/tmp/zou:rw"
    ];
    cmd = ["/opt/venv/bin/rq" "worker" "-c" "zou.job_settings"];
    dependsOn = [
      # "kitsu-db"
      "kitsu-meilisearch"
      "kitsu-redis"
      "kitsu-zou-init-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=/opt/venv/bin/python -c 'import os; from redis import Redis; Redis(host=os.environ.get(\"KV_HOST\", \"redis\"), port=int(os.environ.get(\"KV_PORT\", \"6379\")), socket_connect_timeout=5).ping()'"
      "--health-interval=10s"
      "--health-retries=20"
      "--health-start-period=20s"
      "--health-timeout=5s"
      "--network-alias=zou-jobs"
      "--network=kitsu_internal"
      "--add-host=db:host-gateway"
    ];
  };
  systemd.services."podman-kitsu-zou-jobs" = {
    serviceConfig = {Restart = lib.mkOverride 90 "always";};
    after = [
      "podman-network-kitsu_internal.service"
      "podman-volume-kitsu_previews.service"
      "podman-volume-kitsu_zou_tmp.service"
    ];
    requires = [
      "podman-network-kitsu_internal.service"
      "podman-volume-kitsu_previews.service"
      "podman-volume-kitsu_zou_tmp.service"
    ];
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };

  # Networks
  systemd.services."podman-network-kitsu_internal" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f kitsu_internal";
    };
    script = ''
      podman network inspect kitsu_internal || podman network create kitsu_internal
    '';
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };
  systemd.services."podman-network-kitsu_web" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f kitsu_web";
    };
    script = ''
      podman network inspect kitsu_web || podman network create kitsu_web
    '';
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };

  # Volumes
  systemd.services."podman-volume-kitsu_backups" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect kitsu_backups || podman volume create kitsu_backups
    '';
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };
  systemd.services."podman-volume-kitsu_meili" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect kitsu_meili || podman volume create kitsu_meili
    '';
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };
  systemd.services."podman-volume-kitsu_pgdata" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect kitsu_pgdata || podman volume create kitsu_pgdata
    '';
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };
  systemd.services."podman-volume-kitsu_previews" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect kitsu_previews || podman volume create kitsu_previews
    '';
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };
  systemd.services."podman-volume-kitsu_traefik_letsencrypt" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect kitsu_traefik_letsencrypt || podman volume create kitsu_traefik_letsencrypt
    '';
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };
  systemd.services."podman-volume-kitsu_zou_tmp" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect kitsu_zou_tmp || podman volume create kitsu_zou_tmp
    '';
    partOf = ["podman-compose-kitsu-root.target"];
    wantedBy = ["podman-compose-kitsu-root.target"];
  };

  # Builds
  systemd.services."podman-build-kitsu-db-backup" = {
    path = [pkgs.podman pkgs.git];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /home/guz/.temp/Kitsu-Docker-Prod/backups
      podman build -t ghcr.io/ahmed-hindy/kitsu-db-backup:main .
    '';
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-kitsu-root" = {
    wantedBy = ["multi-user.target"];
  };

  sops.secrets = {
    "containers/kitsu/env" = {
      # owner = "kitsu";
      restartUnits = pipe config.virtualisation.oci-containers [
        (filterAttrs (n: _: hasPrefix "kitsu-" n))
        (mapAttrsToList (n: _: "podman-${n}.service"))
      ];
    };
  };

  systemd.tmpfiles.rules = pipe config.virtualisation.oci-containers.containers [
    (filterAttrs (n: _: hasPrefix "kitsu-" n))
    (mapAttrsToList (n: v: (pipe v.volumes [
      (filter (v: hasPrefix "/var/lib/kitsu" v))
      (map (v: splitString ":" v))
      (map (v: elemAt v 0))
      (filter (v: v != ""))
      (map (v: "d ${v} 0775 root root"))
    ])))
    flatten
  ];
}
