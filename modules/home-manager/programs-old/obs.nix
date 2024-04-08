{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.obs;
in {
  imports = [];
  options.obs = with lib;
  with lib.types; {
    enable = mkEnableOption "";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      obs-studio
      obs-cli
      obs-studio-plugins.wlrobs
      obs-studio-plugins.obs-pipewire-audio-capture
      obs-studio-plugins.obs-vkcapture
    ];
  };
}
