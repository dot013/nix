{
  mkNixPak,
  pkgs,
  ...
}:
mkNixPak {
  config = {sloth, ...}: {
    app.package = pkgs.brave;

    imports = [
      ./modules/gui-base.nix
    ];

    dbus.policies = {
      "org.freedesktop.FileManager1" = "talk";
      "org.freedesktop.Notifications" = "talk";
      "org.freedesktop.ScreenSaver" = "talk";
      "org.freedesktop.secrets" = "talk";
      "org.kde.kwalletd5" = "talk";
      "org.kde.kwalletd6" = "talk";
      "org.gnome.SessionManager" = "talk";
      "org.gnome.ScreenSaver" = "talk";
      "org.gnome.Mutter.IdleMonitor.*" = "talk";
      "org.cinnamon.ScreenSaver" = "talk";
      "org.mate.ScreenSaver" = "talk";
      "org.xfce.ScreenSaver" = "talk";
      "org.mpris.MediaPlayer2.brave.*" = "own";
    };

    bubblewrap = {
      network = true;
      shareIpc = true;

      bind.rw = [
        (sloth.concat' sloth.xdgConfigHome "/BraveSoftware")
        (sloth.concat' sloth.xdgCacheHome "/BraveSoftware")

        "/etc/brave"

        (sloth.concat' sloth.homeDir "/Downloads")
      ];
    };
  };
}
