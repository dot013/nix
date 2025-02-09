{
  config,
  lib,
  pkgs,
  sloth,
  ...
}: {
  config = {
    dbus.policies = {
      "${config.flatpak.appId}" = "own";
      "org.freedesktop.DBus" = "talk";
      "org.gtk.vfs.*" = "talk";
      "org.gtk.vfs" = "talk";
      "ca.desrt.dconf" = "talk";
      "org.freedesktop.portal" = "talk";
      "org.a11y.Bus" = "talk";
    };

    gpu.enable = lib.mkDefault true;
    gpu.provider = "bundle";

    fonts.enable = true;

    locale.enable = true;

    bubblewrap = {
      network = lib.mkDefault false;

      sockets = {
        wayland = true;
        pulse = true;
      };

      bind.rw = [
        [sloth.appCacheDir sloth.xdgCacheHome]
        (sloth.concat' sloth.xdgCacheHome "/fontconfig")
        (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")

        (sloth.concat' sloth.runtimeDir "/at-spi/bus")
        (sloth.concat' sloth.runtimeDir "/gvfsd")
      ];
      bind.ro = [
        (sloth.concat' sloth.runtimeDir "/doc")

        # Follow user theme

        ## Access to user theme config
        (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
        (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
        (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
        (sloth.concat' sloth.xdgConfigHome "/fontconfig")

        ## Access to user themes
        (sloth.concat' sloth.homeDir "/.themes")
        (sloth.concat' sloth.homeDir "/.icons")
      ];

      env = {
        "XDG_DATA_DIRS" = lib.makeSearchPath "share" (with pkgs; [
          adwaita-icon-theme
          shared-mime-info
        ]);
        "XCURSOR_PATH" = lib.concatStringsSep ":" (with pkgs; [
          "${adwaita-icon-theme}/share/icons"
          "${adwaita-icon-theme}/share/pixmaps"
        ]);
      };
    };
  };
}
