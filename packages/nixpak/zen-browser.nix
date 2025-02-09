{
  mkNixPak,
  pkgs,
  self,
  ...
}:
mkNixPak {
  config = {sloth, ...}: {
    app.package = self.packages.${pkgs.system}.zen-browser;

    imports = [
      ./modules/gui-base.nix
    ];

    dbus.policies = {
      "org.freedesktop.FileManager1" = "talk";
      "org.freedesktop.ScreenSaver" = "talk";
      "org.gnome.ScreenSaver" = "talk";
      "org.mozilla.zen.*" = "own";
      "org.mpris.MediaPlayer2.firefox.*" = "own";
    };

    bubblewrap = {
      network = true;
      shareIpc = true;

      bind.rw = [
        (sloth.concat' sloth.homeDir "/.zen")
        (sloth.concat' sloth.xdgCacheHome "/zen")

        (sloth.concat' sloth.homeDir "/Downloads")
      ];
    };
  };
}
