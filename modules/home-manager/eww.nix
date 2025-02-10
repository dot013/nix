{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.eww-custom;

  eww = cfg.package;
  ewwBin = lib.getExe eww;

  # https://github.com/fufexan/dotfiles/blob/eww/home/services/eww/default.nix
  reloadScript = let
    systemctl = lib.getExe' pkgs.systemdUkify "systemctl";
  in
    pkgs.writeShellScript "reload_eww" ''
      ${systemctl} --user restart "eww"

      readarray -t windows < $(${ewwBin} list-windows)

      for w in "$${windows[@]}"; do
        ${systemctl} --user restart "eww-open@$w"
      done
    '';
in {
  options.programs.eww-custom = with lib; {
    enable = mkEnableOption "";
    package = mkOption {
      type = with types; package;
      default = pkgs.eww;
    };

    widgets = mkOption {
      type = with types; either path lines;
    };
    style = mkOption {
      type = with types; either path lines;
    };

    autoReload = mkOption {
      type = with types; bool;
      default = true;
    };
    addPath = mkOption {
      type = with types; listOf package;
      default = [];
    };
  };
  config = lib.mkIf cfg.enable {
    xdg.configFile."eww/eww.yuck" =
      (
        if builtins.isPath cfg.widgets
        then {
          source = cfg.widgets;
        }
        else {
          text = cfg.widgets;
        }
      )
      // {
        onChange =
          if cfg.autoReload
          then reloadScript.outPath
          else "";
      };
    xdg.configFile."eww/eww.scss" =
      (
        if builtins.isPath cfg.style
        then {
          source = cfg.style;
        }
        else {
          text = cfg.style;
        }
      )
      // {
        onChange =
          if cfg.autoReload
          then reloadScript.outPath
          else "";
      };

    home.packages = [eww];

    systemd.user.services = {
      "eww" = {
        Unit = {
          PartOf = ["graphical-session.target"];
        };
        Service = {
          Type = "exec";
          Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath cfg.addPath}";
          ExecStart = "${ewwBin} daemon --no-daemonize";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };

      # https://github.com/Loara/eww-systemd/blob/master/eww-open%40.service
      "eww-open@" = {
        Unit = {
          Requires = ["eww.service"];
          After = ["eww.service"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${ewwBin} open --no-daemonize \"%i\"";
          ExecStop = "${ewwBin} close --no-daemonize \"%i\"";
          RemainAfterExit = "yes";
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    };
  };
}
