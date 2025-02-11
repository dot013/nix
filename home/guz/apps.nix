{...}: {
  services.flatpak.packages = [
    "com.bitwarden.desktop"
    "io.freetubeapp.FreeTube"
    "org.kde.krita"
    "org.inkscape.Inkscape"
    "md.obsidian.Obsidian"
    "com.github.vikdevelop.photopea_app"
    "com.rustdesk.RustDesk"
    "com.valvesoftware.Steam"
    "dev.vencord.Vesktop"
  ];
  services.flatpak.overrides = {
    "com.bitwarden.desktop" = {Context.sockets = ["x11"];};
    "com.github.vikdevelop.photopea_app" = {Context.sockets = ["x11"];};
    "dev.vencord.Vesktop" = {Context.sockets = ["x11"];};
  };
}
