{
  config,
  lib,
  pkgs,
  self,
  ...
}:
with lib; let
  cfg = config.services.playit;
in {
  options.services.playit = {
    enable = lib.mkEnableOption "Playit Service";
    package = mkOption {
      type = with types; package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.playit-agent;
      description = "playit binary to run";
    };
    secretPath = mkOption {
      type = with types; path;
      description = "Path to TOML file containing secret";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    systemd.services.playit = {
      description = "Playit.gg agent";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = ["network-online.target"];
      environment = {
        SECRET_PATH = "%d/secret";
      };
      serviceConfig = {
        ExecStart = ''${lib.getExe cfg.package} --stdout --secret_wait --secret_path "''${SECRET_PATH}" start'';
        Restart = "on-failure";
        StateDirectory = "playit";
        LoadCredential = [
          "secret:${cfg.secretPath}"
        ];
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        DeviceAllow = [""];
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        DynamicUser = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        ProtectClock = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = [];
      };
    };
  };
}
