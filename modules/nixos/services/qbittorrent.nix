{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.qbittorrent;
  UID = 888;
  GID = 888;
in {
  options.services.qbittorrent = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    dataDir = mkOption {
      type = path;
      default = "/var/lib/qbittorrent";
    };
    user = mkOption {
      type = str;
      default = "qbittorrent";
    };
    group = mkOption {
      type = str;
      default = "qbittorrent";
    };
    port = mkOption {
      type = port;
      default = 8080;
    };
    openFirewall = mkOption {
      type = bool;
      default = false;
    };
    package = mkOption {
      type = package;
      default = pkgs.qbittorrent-nox;
    };
  };
  config = with lib;
    mkIf cfg.enable {
      networking.firewall = mkIf cfg.openFirewall {
        allowedTCPPorts = [cfg.port];
      };

      systemd.services.qbittorrent = {
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          ExecStartPre = let
            preStartScript = pkgs.writeScript "qbittorrent-run-prestart" ''
              #!${pkgs.bash}/bin/bash
              if ! test -d "$QBT_PROFILE"; then
                echo "Creating qBittorrent data directory in: $QBT_PROFILE"
                install -d -m 0755 -o "${cfg.user}" -g "${cfg.group}" "$QBT_PROFILE"
                fi
            '';
          in "!${preStartScript}";
          ExecStart = "${cfg.package}/bin/qbittorrent-nox";
          Restart = "on-success";
        };
        environment = {
          QBT_PROFILE = cfg.dataDir;
          QBT_WEBUI_PORT = toString cfg.port;
        };
      };

      users.users."${cfg.user}" = {
        group = cfg.group;
        uid = UID;
      };
      users.groups."${cfg.group}" = {
        gid = GID;
      };
    };
}
