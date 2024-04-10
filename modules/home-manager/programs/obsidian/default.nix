{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.obsidian;
  vaultCmd = pkgs.writeShellScriptBin "vault" ''
    function awk() { ${pkgs.gawk}/bin/awk "$@"; }
    function git() { ${pkgs.git}/bin/git "$@"; }
    function gum() { ${pkgs.gum}/bin/gum "$@"; }

    ${builtins.readFile ./vault.sh}
  '';
in {
  imports = [];
  options.programs.obsidian = with lib;
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
  config = with lib;
    mkIf cfg.enable {
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
