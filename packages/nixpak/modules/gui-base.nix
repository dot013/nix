{
  config,
  lib,
  pkgs,
  sloth,
  ...
}: {
  config = with lib; {
    dbus.policies = {
      "${config.flatpak.appId}" = "own";
      "org.freedesktop.DBus" = mkDefault "talk";
      "org.gtk.vfs.*" = mkDefault "talk";
      "org.gtk.vfs" = mkDefault "talk";
      "ca.desrt.dconf" = mkDefault "talk";
      "org.freedesktop.portal" = mkDefault "talk";
      "org.a11y.Bus" = mkDefault "talk";
    };

    gpu.enable = mkDefault true;
    gpu.provider = mkDefault "bundle";

    fonts.enable = mkDefault true;

    locale.enable = mkDefault true;

    bubblewrap = {
      network = mkDefault false;

      sockets = {
        wayland = mkDefault true;
        pulse = mkDefault true;
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
        "XDG_DATA_DIRS" = makeSearchPath "share" (with pkgs; [
          adwaita-icon-theme
          shared-mime-info
        ]);
        "XCURSOR_PATH" = concatStringsSep ":" (with pkgs; [
          "${adwaita-icon-theme}/share/icons"
          "${adwaita-icon-theme}/share/pixmaps"
        ]);
      };
    };
  };
}
