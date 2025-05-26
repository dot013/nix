{
  self,
  pkgs,
  ...
}: {
  services.flatpak.packages = [
    # Management
    "com.bitwarden.desktop"
    "com.rustdesk.RustDesk"

    # Social
    # "dev.vencord.Vesktop" Currently borked

    # Services
    "app.moosync.moosync"

    # Games
    "org.prismlauncher.PrismLauncher"
    {
      flatpakref = "https://sober.vinegarhq.org/sober.flatpakref";
      sha256 = "1pj8y1xhiwgbnhrr3yr3ybpfis9slrl73i0b1lc9q89vhip6ym2l";
    }

    # Note taking
    "md.obsidian.Obsidian"

    # Office
    "org.libreoffice.LibreOffice"

    # Media creation
    "org.beeref.BeeRef"
    "com.github.vikdevelop.photopea_app"
    "org.darktable.Darktable"
    "org.inkscape.Inkscape"
    # "org.kde.krita" Currently borked, mising qt plugin/platform
    "com.obsproject.Studio"
    "org.kde.kdenlive"
    # "fm.reaper.Reaper"

    # 3D modeling
    "net.blockbench.Blockbench"
    "org.blender.Blender"
  ];
  services.flatpak.overrides = {
    "net.blockbench.Blockbench" = {Context.sockets = ["x11"];};
    "com.bitwarden.desktop" = {Context.sockets = ["x11"];};
    "com.github.vikdevelop.photopea_app" = {Context.sockets = ["x11"];};
    "org.prismlauncher.PrismLauncher" = {Context.sockets = ["x11"];};
    # "dev.vencord.Vesktop" = {Context.sockets = ["x11"];};
  };

  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true;

  qt.enable = true;
  home.packages =
    (with pkgs; [
      # Management
      megasync

      # Social
      vesktop

      # Media creation
      krita
      reaper
      ffmpeg
      exiftool
      # davinci-resolve # Currently borked

      # Keyboard
      vial
    ])
    # Utils
    ++ (with self.packages.${pkgs.system}; [
      davincify
      untrack
    ]);
}
