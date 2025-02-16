{pkgs, ...}: {
  services.flatpak.packages = [
    "com.bitwarden.desktop"
    "io.freetubeapp.FreeTube"
    # "org.kde.krita" Currently borked, mising qt plugin/platform
    "org.inkscape.Inkscape"
    "org.libreoffice.LibreOffice"
    "md.obsidian.Obsidian"
    "com.github.vikdevelop.photopea_app"
    "com.rustdesk.RustDesk"
    "dev.vencord.Vesktop"
  ];
  services.flatpak.overrides = {
    "com.bitwarden.desktop" = {Context.sockets = ["x11"];};
    "com.github.vikdevelop.photopea_app" = {Context.sockets = ["x11"];};
    "dev.vencord.Vesktop" = {Context.sockets = ["x11"];};
  };

  qt.enable = true;
  home.packages = with pkgs; [
    krita
  ];
}
