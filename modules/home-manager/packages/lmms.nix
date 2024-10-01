{
  config,
  lib,
  pkgs,
  ...
}: let
  package = pkgs.stdenv.mkDerivation rec {
    pname = "lmms";
    version = "1.2.2";

    src = builtins.fetchGit {
      url = "https://github.com/LMMS/lmms.git";
      ref = "main";
      rev = "729593c0228c2553248099a09f4fcb6dbe8312e1";
      submodules = true;
      shallow = true;
    };

    nativeBuildInputs = with pkgs; [cmake libsForQt5.qt5.qttools pkg-config];

    buildInputs = with pkgs; [
      carla
      alsa-lib
      fftwFloat
      fltk13
      fluidsynth
      lame
      libgig
      libjack2
      libpulseaudio
      libsamplerate
      libsndfile
      libsoundio
      libvorbis
      portaudio
      libsForQt5.qt5.qtbase
      libsForQt5.qt5.qtx11extras
      SDL # TODO: switch to SDL2 in the next version
    ];

    patches = [
      (pkgs.fetchpatch {
        url = "https://raw.githubusercontent.com/archlinux/svntogit-community/cf64acc45e3264c6923885867e2dbf8b7586a36b/trunk/lmms-carla-export.patch";
        sha256 = "sha256-wlSewo93DYBN2PvrcV58dC9kpoo9Y587eCeya5OX+j4=";
      })
    ];

    cmakeFlags = ["-DWANT_QT5=ON"];

    meta = with lib; {
      description = "DAW similar to FL Studio (music production software)";
      mainProgram = "lmms";
      homepage = "https://lmms.io";
      license = licenses.gpl2Plus;
      platforms = ["x86_64-linux" "i686-linux"];
      maintainers = [];
    };
  };
in {
  home.packages = [
    # package
  ];
}
