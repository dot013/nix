{
  config,
  lib,
  pkgs,
  ...
}: {
  # Host specific overrides of the root home
  home-manager.users.guz = let
    cfg = config.home-manager.users.guz;
    hyprcfg = cfg.wayland.windowManager.hyprland.settings;
  in {
    wayland.windowManager.hyprland.settings = {
      "$MONITOR-1" = lib.mkForce "HDMI-A-1";
      "$MONITOR-2" = lib.mkForce "DVI-D-1";
    };
  };
}
