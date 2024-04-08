{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.obsidian;
  vaultCmd = pkgs.writeShellScriptBin "vault" ''
    command="$1";

    if [[ "$command" == "sync" ]]; then
      git="${pkgs.git}/bin/git";
      date="$(date +%F) $(date +%R)"

      cd ${cfg.vaultDir}
      $git pull
      if [[ "$(echo "$($git diff --shortstat)" | awk '{print $1}')" -ne "" ]]; then
        $git commit -m "vault backup: $date" -a
      fi
      $git push
    fi
  '';
in {
  imports = [];
  options.obsidian = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    vaultCmd = mkOption {
      type = bool;
      default = false;
    };
    vaultDir = mkOption {
      type = str;
      default = "${config.home.homeDirectory}/.vault";
    };
  };
  config = lib.mkIf cfg.enable {
    services.flatpak.packages = [
      "md.obsidian.Obsidian"
    ];
    home.packages = [
      (
        if cfg.vaultCmd
        then vaultCmd
        else null
      )
    ];
  };
}
