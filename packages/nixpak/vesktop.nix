{
  mkNixPak,
  pkgs,
  ...
}:
mkNixPak {
  config = {sloth, ...}: {
    app.package = pkgs.vesktop;

    imports = [
      ./modules/gui-base.nix
    ];

    dbus.policies = {
      "org.kde.StatusNotifierWatcher" = "talk";
      "com.canonical.AppMenu.Registrar" = "talk";
      "org.freedesktop.Notifications" = "talk";
    };

    bubblewrap = {
      network = true;
      shareIpc = true;

      sockets.pipewire = true;
      sockets.pulse = false;

      bind.rw = [
        (sloth.concat' sloth.xdgConfigHome "/vesktop")
      ];
      bind.ro = [
        (sloth.concat' sloth.homeDir "/Videos")
        (sloth.concat' sloth.homeDir "/Pictures")
        (sloth.concat' sloth.homeDir "/Downloads")
      ];
      bind.dev = ["all"];
    };
  };
}
