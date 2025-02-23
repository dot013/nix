{pkgs, ...}: {
  services.flatpak.packages = [
    "org.blender.Blender"
    "org.darktable.Darktable"
    "com.bitwarden.desktop"
    "io.freetubeapp.FreeTube"
    # "org.kde.krita" Currently borked, mising qt plugin/platform
    "org.inkscape.Inkscape"
    "org.libreoffice.LibreOffice"
    "md.obsidian.Obsidian"
    "com.github.vikdevelop.photopea_app"
    "com.rustdesk.RustDesk"
    # "dev.vencord.Vesktop" Currently borked
  ];
  services.flatpak.overrides = {
    "com.bitwarden.desktop" = {Context.sockets = ["x11"];};
    "com.github.vikdevelop.photopea_app" = {Context.sockets = ["x11"];};
    # "dev.vencord.Vesktop" = {Context.sockets = ["x11"];};
  };

  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true;

  qt.enable = true;
  home.packages = with pkgs; [
    krita
    vesktop
  ];
}
