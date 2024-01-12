{ lib, config, pkgs, ... }:

let
  cfg = config.eww;
  ewwDir = "${config.xdg.configHome}/eww";
in
{
  imports = [ ];
  options.eww = with lib; with lib.types; {
    enable = mkEnableOption "";
  };
  config = lib.mkIf cfg.enable {

    home.file."${ewwDir}/eww.yuck".source = ./eww.yuck;
    home.file."${ewwDir}/eww.scss".source = ./eww.scss;

    home.file."${ewwDir}/vars.yuck".text = ''
    '';

    home.file."${ewwDir}/vars.scss".text = ''
      $color-accent: #${config.theme.accent};
      $foreground: rgba(#${config.colorScheme.colors.base03}, 1);
      $background: rgba(#${config.colorScheme.colors.base00}, 1);

      $shadow: 2px 2px 2px rgba(0, 0, 0, 0.2);
      $border-radius: 5px;

      @mixin box-style {
        border-radius: $border-radius;
        box-shadow: $shadow;
        background-color: $color-background;
      }
    '';
  };
}

