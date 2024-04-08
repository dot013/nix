{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.nih.sound;
in {
  imports = [];
  options.nih.sound = with lib;
  with lib.types; {
    enable = mkOption {
      type = bool;
      default = true;
    };
    pipewire.enable = mkOption {
      type = bool;
      default = true;
    };
    pulseaudio.enable = mkOption {
      type = bool;
      default = !cfg.pipewire.enable;
    };
  };
  config = with lib;
    mkIf cfg.enable {
      sound.enable = true;
      hardware.pulseaudio.enable = cfg.pulseaudio.enable;
      security.rtkit.enable = true;
      services.pipewire = mkIf cfg.pipewire.enable {
        enable = true;
        alsa.enable = mkDefault true;
        alsa.support32Bit = mkDefault true;
        pulse.enable = mkDefault true;
        wireplumber.enable = mkDefault true;
      };
    };
}
