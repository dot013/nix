{
  lib,
  osConfig,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    exiftool
    ffmpeg
    krita
    reaper
  ];

}
