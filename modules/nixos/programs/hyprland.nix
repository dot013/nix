{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.programs.hyprland;
in {
  imports = [];
  options.programs.hyprland = with lib;
  with lib.types; {
    useFlakes = mkOption {
      type = bool;
      default = true;
    };
  };
  config = with lib;
    mkIf cfg.enable {
      programs.hyprland = {
        xwayland.enable = mkDefault true;
        package = mkDefault (
          if cfg.useFlakes
          then inputs.hyprland.packages."${pkgs.system}".hyprland
          else pkgs.hyprland
        );
        portalPackage = mkDefault (
          if cfg.useFlakes
          then inputs.xdg-desktop-portal-hyprland.packages."${pkgs.system}".xdg-desktop-portal-hyprland
          else pkgs.xdg-desktop-portal-hyprland
        );
      };
      xdg.portal.enable = true;
      xdg.portal.extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
}
