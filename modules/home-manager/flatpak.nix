{ config, inputs, lib, ... }:

let
  cfg = config.flatpak;
in
{
  imports = [
    inputs.flatpaks.homeManagerModules.default
  ];
  options.flatpak = {
    enable = lib.mkEnableOption "Enable flatpak module";
    packages = lib.mkOption {
      default = [ ];
    };
  };
  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enableModule = true;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      };
      packages = cfg.packages;
    };
  };
}
