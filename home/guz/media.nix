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

  # Easier access to krita
  home.file.".bin/ffmpeg" = {
    executable = true;
    source = lib.getExe pkgs.ffmpeg;
  };
}
