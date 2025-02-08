{
  config,
  lib,
  pkgs,
  ...
}: {
  # Rofi themes
  home.file."${config.xdg.configHome}/rofi/launcher.rasi".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/adi1090x/rofi/2e0efe5054ac7eb502a585dd6b3575a65b80ce72/files/launchers/type-1/style-3.rasi";
    hash = "sha256-6Zj1mxRDkARdIWiin3J7BPp/vqfktvidUK/yqLN+k1o=";
  };
  home.file."${config.xdg.configHome}/rofi/shared/colors.rasi".text = with config.lib.stylix.colors; ''
    * {
        background:     #${base02}FF;
        background-alt: #${base01}FF;
        foreground:     #${base05}FF;
        selected:       #${base02}FF;
        active:         #${base00}FF;
        urgent:         #${base08}FF;
    }
  '';
  home.file."${config.xdg.configHome}/rofi/shared/fonts.rasi".text = ''
    * {
      font: "${config.stylix.fonts.sansSerif.name}";
    }
  '';
}
