{
  lib,
  appimageTools,
  makeDesktopItem,
  ...
}: let
  name = "Audacity 4";
  pname = "audacity4";
  version = "4.0.0.253640331";

  src = ./AudacityNightly-4.0.0.253640331-x86_64.AppImage;
  # appimageContents = appimageTools.extractType1 {inherit name src;};
in
  appimageTools.wrapType2 rec {
    inherit name pname version src;

    extraInstallCommands = ''
      mkdir -p $out/bin
      mkdir -p $out/share/applications
      cat <<INI > $out/share/applications/${pname}.desktop
      [Desktop Entry]
      Name=${name}
      Exec=$out/bin/${pname} %f
      Type=Application
      INI
    '';

    meta = {
      platforms = ["x86_64-linux"];
    };
  }
