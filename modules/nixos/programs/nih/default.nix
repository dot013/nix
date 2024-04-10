{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.nih;
  cli = pkgs.writeShellScriptBin "nih" ''
    # Since alias= doesn't work in bash scripts
    function alejandra() { ${pkgs.alejandra}/bin/alejandra "$@"; }
    function git() { ${pkgs.git}/bin/git "$@"; }
    function gum() { ${pkgs.gum}/bin/gum "$@"; }
    function lazygit() { ${pkgs.lazygit}/bin/lazygit "$@"; }
    function notify-send() {
      (${pkgs.libnotify}/bin/notify-send "$@" &>/dev/null || echo "")
    }
    function mktemp() { ${pkgs.mktemp}/bin/mktemp "$@"; }
    # function prettier() { ${pkgs.nodePackages.prettier}/lib/node_modules/.bin/prettier ; }
    function shellharden() { ${pkgs.shellharden}/bin/shellharden "$@"; }
    # function shfmt() { ${pkgs.shfmt}/bin/shfmt "$@"; }
    function sops() { ${pkgs.sops}/bin/sops "$@"; }

    flake_dir="${toString cfg.flakeDir}";
    host="${toString cfg.host}";


    ${builtins.readFile ./cli.sh}
  '';
in {
  imports = [];
  options.programs.nih = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    host = mkOption {
      type = str;
    };
    flakeDir = mkOption {
      type = str;
    };
    cli = mkOption {
      type = bool;
      default = cfg.enable;
    };
  };
  config = with lib;
    mkIf cfg.enable {
      environment.systemPackages = [
        cli
      ];
    };
}
