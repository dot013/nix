{
  self,
  pkgs,
  ...
}: {
  services.flatpak.packages = [
    "org.blender.Blender"
    "org.beeref.BeeRef"
    "com.bitwarden.desktop"
    "org.darktable.Darktable"
    "io.freetubeapp.FreeTube"
    # "org.kde.krita" Currently borked, mising qt plugin/platform
    "org.inkscape.Inkscape"
    "org.libreoffice.LibreOffice"
    "md.obsidian.Obsidian"
    "com.github.vikdevelop.photopea_app"
    "org.prismlauncher.PrismLauncher"
    "com.rustdesk.RustDesk"
    {
      flatpakref = "https://sober.vinegarhq.org/sober.flatpakref";
      sha256 = "1pj8y1xhiwgbnhrr3yr3ybpfis9slrl73i0b1lc9q89vhip6ym2l";
    }
    # "dev.vencord.Vesktop" Currently borked
  ];
  services.flatpak.overrides = {
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
      megasync

      vesktop

      # Media
      ffmpeg
      exiftool
      krita
      davinci-resolve
    ])
    # Utils
    ++ (with self.packages.${pkgs.system}; [
      davincify
      untrack
    ]);
}
