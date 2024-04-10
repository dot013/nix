{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.hyprland;
  hyprconfValueType = with lib.types;
    nullOr (oneOf [
      bool
      int
      float
      str
      path
      (attrsOf hyprconfValueType)
      (listOf hyprconfValueType)
    ]);
in {
  imports = [];
  options.programs.hyprland = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    settings = mkOption {
      type = attrsOf hyprconfValueType;
      default = {};
    };
  };
  config = with lib;
    mkIf cfg.enable {
      wayland.windowManager.hyprland.enable = true;
      wayland.windowManager.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      wayland.windowManager.hyprland.xwayland.enable = true;
      wayland.windowManager.hyprland.systemd.enable = true;

      wayland.windowManager.hyprland.settings = cfg.settings;
    };
}
