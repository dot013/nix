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

    function nih-forgejo() {
    ${
      if config.services.forgejo.actions.enable
      then ''
        sudo --user=${config.services.forgejo.user} \
          ${config.services.forgejo.package}/bin/gitea \
          --work-path ${config.services.forgejo.stateDir} \
          "$@"
      ''
      else ''
        gum log --structured --prefix 'nih' --level error "Forgejo action runnser service is not enabled"
      ''
    }
    }

    function nih-forgejo-act() {
    ${
      if config.services.forgejo.enable
      then ''
        sudo --user=${config.services.forgejo.user} \
          ${config.services.gitea-actions-runner.package}/bin/act_runner \
          --config /var/lib/gitea-runner/forgejo${toString config.services.forgejo.settings.server.HTTP_PORT} \
          "$@"
      ''
      else ''
        gum log --structured --prefix 'nih' --level error "Forgejo service is not enabled"
      ''
    }
    }

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
