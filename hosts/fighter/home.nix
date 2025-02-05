{lib, ...}: {
  # Host specific overrides of the root home
  home-manager.users.guz = {
    wayland.windowManager.hyprland.settings = {
      "$MONITOR-1" = lib.mkForce "eDP-1";
    };
  };
}
