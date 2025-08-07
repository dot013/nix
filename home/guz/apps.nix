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
    # "net.pcsx2.PCSX2" Currently borked, mising qt plugin/platform
    {
      flatpakref = "https://sober.vinegarhq.org/sober.flatpakref";
      sha256 = "1pj8y1xhiwgbnhrr3yr3ybpfis9slrl73i0b1lc9q89vhip6ym2l";
    }

    # Office
    "org.libreoffice.LibreOffice"

    # Media creation
    "fr.natron.Natron"
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

    # For sites that are incompatible with qutebrowser
    "io.gitlab.librewolf-community"
  ];
  services.flatpak.overrides = {
    "net.blockbench.Blockbench" = {Context.sockets = ["x11"];};
    "com.bitwarden.desktop" = {Context.sockets = ["x11"];};
    "fr.natron.Natron" = {Context.sockets = ["x11"];};
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

      # Games
      lutris
      winePackages.waylandFull
      pcsx2
      mono # For city skylines mods

      # Social
      vesktop

      # Media creation
      krita
      reaper
      ffmpeg
      exiftool

      # Keyboard
      vial

      davinci-resolve
    ])
    # Utils
    ++ (with self.packages.${pkgs.system}; [
      davincify
      untrack
    ]);

  programs.distrobox.enable = true;
  programs.distrobox.containers = {
    "davincibox" = {
      image = "ghcr.io/zelikos/davincibox-opencl:latest";
    };
  };
}
