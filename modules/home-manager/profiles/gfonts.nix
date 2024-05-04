{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.profiles.gfonts;
in {
  options.profiles.gfonts = with lib;
  with lib.types; {
    enable = mkEnableOption "";
  };
  config = with lib;
    mkIf cfg.enable {
      fonts.fontconfig.enable = true;
      home.packages = with pkgs; [
        (nerdfonts.override {fonts = ["FiraCode"];})
        (google-fonts.override {fonts = ["Gloock" "Cinzel"];})
        (stdenv.mkDerivation rec {
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
    };
}
