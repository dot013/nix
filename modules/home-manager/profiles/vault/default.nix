{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.vault;
  vault = pkgs.writeShellScriptBin "vault" ''
    VAULT_DIR="${cfg.vaultDir}"

    ${builtins.readFile ./cli.sh}
  '';
in {
  imports = [];
  options.profiles.vault = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    vaultDir = mkOption {
      type = either path str;
      default = "${config.home.homeDirectory}/.vault";
    };
    periodicPush = mkOption {
      type = bool;
      default = true;
    };
  };
  config = with lib;
    mkIf cfg.enable {
      services.flatpak.packages = [
        "md.obsidian.Obsidian"
      ];
      home.packages = [
        vault
      ];

      systemd.user.services = mkIf cfg.periodicPush {
        vault-periodic-push = {
          Install = {
            WantedBy = ["default.target"];
          };
          Service = let
            script = pkgs.writeShellScriptBin "vault-periodic-push" ''
              ${vault} sync
            '';
          in {
            Type = "oneshot";
            RemainAfterExit = true;
            StandardOutput = "journal";
            ExecStart = script;
            ExecStop = script;
          };
        };
      };
      systemd.user.timers = mkIf cfg.periodicPush {
        vault-periodic-push = {
          Install = {
            WantedBy = ["timers.target"];
          };
          Timer = {
            OnBootSec = "1min";
            OnUnitActiveSec = "2h";
          };
        };
      };
    };
}
