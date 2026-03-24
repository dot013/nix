{
  appimageTools,
  fetchurl,
  lib,
  ...
}:
appimageTools.wrapType2 rec {
  name = "Audacity";
  pname = "audacity";
  version = "4.0.0-alpha-2";
  src = fetchurl {
    url = "https://github.com/audacity/audacity/releases/download/Audacity-${version}/Audacity-4.0.0.253031629.f3e3e3b.-x86_64.AppImage";
    hash = "sha256-HMT01OOSSXe609A6SlYBBdg69zyuciNLl9mzTFRByAE=";
  };
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
    description = "Sound editor with graphical UI";
    mainProgram = "audacity";
    homepage = "https://www.audacityteam.org";
    changelog = "https://github.com/audacity/audacity/releases";
    license = with lib.licenses; [
      gpl2Plus
      # Must be GPL3 when building with "technologies that require it,
      # such as the VST3 audio plugin interface".
      # https://github.com/audacity/audacity/discussions/2142.
      gpl3
      # Documentation.
      cc-by-30
    ];
    maintainers = with lib.maintainers; [
      veprbl
      wegank
    ];
    platforms = lib.platforms.unix;
  };
}
