{
  mkNixPak,
  pkgs,
  ...
}:
mkNixPak {
  config = {sloth, ...}: {
    app.package = pkgs.bitwarden-desktop;

    imports = [
      ./modules/gui-base.nix
    ];

    dbus.policies = {
      "org.kde.StatusNotifierWatcher" = "talk";
      "org.freedesktop.Notifications" = "talk";
      "org.freedesktop.secrets" = "talk";
      "com.canonical.AppMenu.Registrar" = "talk";
      # Lock on lockscreen
      "org.gnome.ScreenSaver" = "talk";
      "org.freedesktop.ScreenSaver" = "talk";
    };

    bubblewrap = {
      network = true;
      shareIpc = true;

      bind.rw = [
        (sloth.concat' sloth.xdgConfigHome "/Bitwarden")
      ];
    };
  };
}
