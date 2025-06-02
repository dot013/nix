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

  # Fonts
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts = with config.stylix.fonts; {
    sansSerif = [sansSerif.name];
    serif = [serif.name];
    monospace = [monospace.name];
    emoji = [emoji.name];
  };
  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font";
    };
  };
  home.packages = [
    (pkgs.stdenv.mkDerivation rec {
      name = "Cal Sans";
      pname = "calsans";
      version = "1.0.0";
      src = pkgs.fetchzip {
        url = "https://github.com/calcom/font/releases/download/v${version}/CalSans_Semibold_v${version}.zip";
        stripRoot = false;
        hash = "sha256-JqU64JUgWimJgrKX3XYcml8xsvy//K7O5clNKJRGaTM=";
      };
      installPhase = ''
        runHook preInstall
        install -m444 -Dt $out/share/fonts/truetype fonts/webfonts/*.ttf
        runHook postInstall
      '';
      meta = with lib; {
        homepage = "https://github.com/calcom/font";
        license = licenses.ofl;
        platforms = platforms.all;
      };
    })
  ];
}
