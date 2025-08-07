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
    "org.vinegarhq.Sober"

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
    "org.vinegarhq.Sober" = {Context.device = "input";};
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

  xdg.desktopEntries."davinci-resolve-zsh" = rec {
    name = "Davinci Resolve (Zsh)";
    genericName = name;
    mimeType = ["application/x-resolveproj"];
    # INFO: For some reason this works and removes the "Unsupported GPU" error
    exec = "${lib.getExe config.programs.zsh.package} -c ${lib.getExe pkgs.davinci-resolve}";
  };

  # TODO: Remove this
  programs.distrobox.enable = true;
  programs.distrobox.containers = {
    "davincibox" = {
      image = "ghcr.io/zelikos/davincibox-opencl:latest";
    };
  };
}
