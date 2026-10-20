{
  config,
  lib,
  pkgs,
  self,
  ...
}:
with lib; let
  cfg = config.services.clustta;
in {
  options.services.clustta = {
    enable = mkOption {
      type = with types; bool;
      default = false;
    };
    baseDir = mkOption {
      type = with types; str;
      default = "/var/lib/clustta";
    };
    settings = {
      host = mkOption {
        type = with types; str;
        default = "0.0.0.0";
      };
      port = mkOption {
        type = with types; either port str;
        default = 7774;
      };
      data_dir = mkOption {
        type = with types; str;
        default = "${cfg.baseDir}/data";
      };
      projects_dir = mkOption {
        type = with types; str;
        default = "${cfg.baseDir}/projects";
      };
      shared_projects_dir = mkOption {
        type = with types; str;
        default = "${cfg.baseDir}/shared_projects";
      };
      storage_dir = mkOption {
        type = with types; str;
        default = "${cfg.baseDir}/storage";
      };
      server_url = mkOption {
        type = with types; str;
        default = "";
      };
      server_alt_url = mkOption {
        type = with types; str;
        default = "";
      };
      server_name = mkOption {
        type = with types; str;
        default = "";
      };
      studio_api_key = mkOption {
        type = with types; str;
        default = "";
      };
      studio_users_db = mkOption {
        type = with types; str;
        default = "${cfg.settings.data_dir}/studio_users.db";
      };
      session_db = mkOption {
        type = with types; str;
        default = "${cfg.settings.data_dir}/sessions.db";
      };
      private = mkOption {
        type = with types; bool;
        default = false;
      };
      secure_cookies = mkOption {
        type = with types; bool;
        default = false;
      };
      windows_ui_mode = mkOption {
        type = with types; str;
        default = "console";
      };
      smtp_host = mkOption {
        type = with types; str;
        default = "";
      };
      smtp_port = mkOption {
        type = with types; port;
        default = 0;
      };
      smtp_user = mkOption {
        type = with types; str;
        default = "";
      };
      smtp_password = mkOption {
        type = with types; str;
        default = "";
      };
      smtp_from = mkOption {
        type = with types; str;
        default = "";
      };
      integration_secret_key = mkOption {
        type = with types; str;
        default = "";
      };
      integration_reconcile_interval = mkOption {
        type = with types; str;
        default = "";
      };
    };
    user = mkOption {
      type = with types; str;
      default = "clustta";
    };
    group = mkOption {
      type = with types; str;
      default = "clustta";
    };
  };
  config = mkIf cfg.enable {
    systemd.services."clustta-studio" = {
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      preStart = ''
        cp ${pkgs.writers.writeJSON "studio_config.json" (cfg.settings // {port = toString cfg.settings.port;})} ./studio_config.json
      '';
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${getExe self.packages.${pkgs.stdenv.hostPlatform.system}.clustta} studio";
        WorkingDirectory = cfg.baseDir;
        Restart = "always";
        RuntimeDirectory = "gitea";
        RuntimeDirectoryMode = "0755";
        ProcSubset = "pid";
        ProtectProc = "invisible";
        ReadWritePaths = [
          cfg.baseDir
          cfg.settings.data_dir
          cfg.settings.projects_dir
          cfg.settings.shared_projects_dir
          cfg.settings.storage_dir
        ];
        UMask = "0027";
        TimeoutStartSec = "3m";

        # Sandboxing
        CapabilityBoundingSet = "";
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateMounts = true;
        # System Call Filtering
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "~@cpu-emulation @debug @keyring @mount @obsolete @setuid"
          "setrlimit"
        ];
      };
    };

    users.users."clustta" = mkIf (cfg.user == "clustta") {
      isSystemUser = true;
      group = "${cfg.group}";
      home = "${cfg.baseDir}";
    };
    users.groups."clustta" = mkIf (cfg.group == "clustta") {};

    systemd.tmpfiles.rules = [
      "d '${cfg.settings.data_dir}' 0750 ${cfg.user} ${cfg.group}"
      "d '${cfg.settings.projects_dir}' 0750 ${cfg.user} ${cfg.group}"
      "d '${cfg.settings.shared_projects_dir}' 0750 ${cfg.user} ${cfg.group}"
      "d '${cfg.settings.storage_dir}' 0750 ${cfg.user} ${cfg.group}"
    ];
  };
}
