{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.postiz;

  postizPackage = pkgs.callPackage ({
    stdenv,
    lib,
    makeWrapper,
    pnpm_10_latest,
    nodejs_22,
    fetchFromGitHub,
    fetchPnpmDeps,
    pnpmConfigHook,
    prisma-engines_6,
    openssl,
  }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "postiz";
      version = "2.26.0";

      src = fetchFromGitHub {
        owner = "gitroomhq";
        repo = "postiz-app";
        rev = "v${finalAttrs.version}";
        hash = "sha256-uek5Ri+gUL/bj9tt86rIikEz8xbx4qtIiMJLVImffbQ=";
      };

      pnpmDeps = fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        pnpm = pnpm_10_latest;
        fetcherVersion = 5;
        hash = "sha256-HkYegqJpSy5e2LPXddtZz/njrYSVYDj6jtpV8yI2RIw=";
      };

      nativeBuildInputs = [
        nodejs_22
        pnpmConfigHook
        pnpm_10_latest
        prisma-engines_6
        makeWrapper
      ];

      env = {
        PRISMA_QUERY_ENGINE_LIBRARY = "${prisma-engines_6}/lib/libquery_engine.node";
        PRISMA_QUERY_ENGINE_BINARY = "${prisma-engines_6}/bin/query-engine";
        PRISMA_SCHEMA_ENGINE_BINARY = "${prisma-engines_6}/bin/schema-engine";
      };

      buildPhase = ''
        runHook preBuild

        export NODE_OPTIONS="--max-old-space-size=4096"

        # pnpmConfigHook installs with --ignore-scripts, so generate Prisma client explicitly.
        pnpm exec prisma generate --schema ./libraries/nestjs-libraries/src/database/prisma/schema.prisma

        pnpm run build

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/postiz $out/bin
        cp -a . $out/lib/postiz

        # App start scripts use `dotenv -e ../../.env`; provide an empty file in the store.
        touch $out/lib/postiz/.env

        makeWrapper ${lib.getExe nodejs_22} $out/bin/postiz-backend \
          --chdir "$out/lib/postiz/apps/backend" \
          --prefix PATH : ${lib.makeBinPath [nodejs_22 openssl]} \
          --set NODE_ENV production \
          --set PRISMA_QUERY_ENGINE_LIBRARY "${prisma-engines_6}/lib/libquery_engine.node" \
          --set PRISMA_QUERY_ENGINE_BINARY "${prisma-engines_6}/bin/query-engine" \
          --set PRISMA_SCHEMA_ENGINE_BINARY "${prisma-engines_6}/bin/schema-engine" \
          --add-flags "--experimental-require-module ./dist/apps/backend/src/main.js"

        makeWrapper ${lib.getExe' pnpm_10_latest "pnpm"} $out/bin/postiz-frontend \
          --chdir "$out/lib/postiz/apps/frontend" \
          --prefix PATH : ${lib.makeBinPath [nodejs_22 pnpm_10_latest openssl]} \
          --set NODE_ENV production \
          --set PRISMA_QUERY_ENGINE_LIBRARY "${prisma-engines_6}/lib/libquery_engine.node" \
          --set PRISMA_QUERY_ENGINE_BINARY "${prisma-engines_6}/bin/query-engine" \
          --set PRISMA_SCHEMA_ENGINE_BINARY "${prisma-engines_6}/bin/schema-engine" \
          --add-flags "exec next start"

        makeWrapper ${lib.getExe nodejs_22} $out/bin/postiz-orchestrator \
          --chdir "$out/lib/postiz/apps/orchestrator" \
          --prefix PATH : ${lib.makeBinPath [nodejs_22 openssl]} \
          --set NODE_ENV production \
          --set PRISMA_QUERY_ENGINE_LIBRARY "${prisma-engines_6}/lib/libquery_engine.node" \
          --set PRISMA_QUERY_ENGINE_BINARY "${prisma-engines_6}/bin/query-engine" \
          --set PRISMA_SCHEMA_ENGINE_BINARY "${prisma-engines_6}/bin/schema-engine" \
          --add-flags "--experimental-require-module ./dist/apps/orchestrator/src/main.js"

        runHook postInstall
      '';

      meta = with lib; {
        description = "Postiz social media scheduling application";
        homepage = "https://postiz.com";
        license = licenses.agpl3Only;
        platforms = platforms.linux;
        mainProgram = "postiz-backend";
      };
    })) {};

  runtimeEnvironment =
    {
      NODE_ENV = "production";
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines_6}/lib/libquery_engine.node";
      PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines_6}/bin/query-engine";
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines_6}/bin/schema-engine";

      STORAGE_PROVIDER = cfg.storageProvider;
      UPLOAD_DIRECTORY = cfg.storageDir;
      NEXT_PUBLIC_UPLOAD_DIRECTORY = cfg.storageDir;
    }
    // (optionalAttrs cfg.configureRedis {
      REDIS_URL = "redis://localhost:${toString config.services.redis.servers."postiz".port}";
    });

  commonServiceConfig = {
    User = cfg.user;
    Group = cfg.group;
    WorkingDirectory = cfg.stateDir;
    Restart = "on-failure";
    RestartSec = "5s";

    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    ReadWritePaths = [cfg.stateDir];
  };

  mkServiceConfig = extra:
    mkMerge [
      commonServiceConfig
      (mkIf (cfg.environmentFile != null) {EnvironmentFile = cfg.environmentFile;})
      extra
    ];
in {
  options.services.postiz = {
    enable = mkEnableOption "Postiz";

    package = mkOption {
      type = with types; package;
      default = postizPackage;
      defaultText = literalExpression "pkgs.callPackage ./postiz-package.nix { }";
      description = "The Postiz package to use.";
    };

    user = mkOption {
      type = with types; str;
      default = "postiz";
      description = "User account under which Postiz services run.";
    };

    group = mkOption {
      type = with types; str;
      default = "postiz";
      description = "Group under which Postiz services run.";
    };

    stateDir = mkOption {
      type = with types; str;
      default = "/var/lib/postiz";
      description = "Directory for Postiz runtime state.";
    };

    storageProvider = mkOption {
      type = with types; enum ["local"];
      default = "local";
    };

    storageDir = mkOption {
      type = with types; str;
      default = "${cfg.stateDir}/uploads";
    };

    frontendPort = mkOption {
      type = with types; port;
      default = 4200;
      description = "Port for the Postiz frontend (Next.js).";
    };

    backendPort = mkOption {
      type = with types; port;
      default = 3000;
      description = "Port for the Postiz frontend (Next.js).";
    };

    orchestratorPort = mkOption {
      type = with types; port;
      default = 3002;
      description = "Port for the Postiz frontend (Next.js).";
    };

    environment = mkOption {
      type = with types; attrsOf str;
      default = {};
      example = literalExpression ''
        {
          DATABASE_URL = "postgresql://postiz:postiz@localhost:5432/postiz";
          REDIS_URL = "redis://localhost:6379";
          FRONTEND_URL = "https://postiz.example.com";
          NEXT_PUBLIC_BACKEND_URL = "https://postiz.example.com/api";
          BACKEND_INTERNAL_URL = "http://127.0.0.1:3000";
          JWT_SECRET = "change-me";
        }
      '';
      description = ''
        Environment variables passed to Postiz services.
        Do not put secrets here if your Nix store/world is readable; prefer {option}`services.postiz.environmentFile`.
      '';
    };

    environmentFile = mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/postiz.env";
      description = ''
        Environment file loaded by systemd for Postiz services.
        Useful for secrets such as DATABASE_URL, JWT_SECRET, etc.
      '';
    };

    runMigrate = mkOption {
      type = with types; bool;
      default = false;
      description = ''
        Whether to run `prisma db push` as a oneshot service before starting Postiz.
        Disabled by default; enable only if you intentionally want schema push behavior.
      '';
    };

    configureRedis = mkOption {
      type = with types; bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "postiz") {
      postiz = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.stateDir;
        description = "Postiz service user";
      };
    };

    users.groups = mkIf (cfg.group == "postiz") {
      postiz = {};
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.postiz-migrate = mkIf cfg.runMigrate {
      description = "Postiz database schema push";
      wantedBy = ["multi-user.target"];
      before = [
        "postiz-backend.service"
        "postiz-frontend.service"
        "postiz-orchestrator.service"
      ];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      environment = runtimeEnvironment // cfg.environment;
      serviceConfig = mkServiceConfig {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = mkForce "${cfg.package}/lib/postiz";
      };
      script = ''
        ${getExe pkgs.prisma_6} db push \
          --schema ./libraries/nestjs-libraries/src/database/prisma/schema.prisma
      '';
      preStart = ''
        set -eu

        for _ in $(seq 1 60); do
          echo "Waiting for database"
          nc -z -w 2 192.168.0.101 5433 && break
          sleep 2
        done
        nc -z -w 2 192.168.0.101 5433
        echo "Database ready"
      '';
      path = with pkgs; [nodejs_22 openssl netcat];
    };

    systemd.services.postiz-backend = {
      description = "Postiz backend";
      wantedBy = ["multi-user.target"];
      after =
        ["network-online.target"]
        ++ optional cfg.runMigrate "postiz-migrate.service";
      wants = ["network-online.target"];
      requires = optional cfg.runMigrate "postiz-migrate.service";
      partOf = ["postiz.target"];
      environment =
        runtimeEnvironment
        // {
          PORT = toString cfg.backendPort;
          ORCHESTRATOR_PORT = toString cfg.orchestratorPort;
        }
        // cfg.environment;
      serviceConfig = mkServiceConfig {
        ExecStart = "${cfg.package}/bin/postiz-backend";
      };
      path = with pkgs; [nodejs_22 openssl];
    };

    systemd.services.postiz-frontend = {
      description = "Postiz frontend";
      wantedBy = ["multi-user.target"];
      after =
        ["network-online.target" "postiz-backend.service"]
        ++ optional cfg.runMigrate "postiz-migrate.service";
      wants = ["network-online.target" "postiz-backend.service"];
      partOf = ["postiz.target"];
      environment =
        runtimeEnvironment
        // {
          PORT = toString cfg.frontendPort;
          ORCHESTRATOR_PORT = toString cfg.orchestratorPort;
        }
        // cfg.environment;
      serviceConfig = mkServiceConfig {
        ExecStart = "${cfg.package}/bin/postiz-frontend";
      };
      path = with pkgs; [nodejs_22 openssl pnpm_10_latest];
    };

    systemd.services.postiz-orchestrator = {
      description = "Postiz orchestrator";
      wantedBy = ["multi-user.target"];
      after =
        ["network-online.target" "postiz-backend.service"]
        ++ optional cfg.runMigrate "postiz-migrate.service";
      wants = ["network-online.target" "postiz-backend.service"];
      partOf = ["postiz.target"];
      environment =
        runtimeEnvironment
        // {
          ORCHESTRATOR_PORT = toString cfg.orchestratorPort;
        }
        // cfg.environment;
      serviceConfig = mkServiceConfig {
        ExecStart = "${cfg.package}/bin/postiz-orchestrator";
      };
      path = with pkgs; [nodejs_22 openssl];
    };

    systemd.targets.postiz = {
      description = "Postiz services";
      wantedBy = ["multi-user.target"];
      wants = [
        "postiz-backend.service"
        "postiz-frontend.service"
        "postiz-orchestrator.service"
      ];
    };

    services.redis.servers."postiz" = mkIf cfg.configureRedis {
      enable = true;
      port = 6379;
    };
    systemd.services."redis-postiz" = mkIf cfg.configureRedis {
      before = ["postiz.target"];
    };
  };
}
