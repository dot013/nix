{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.programs.prismlauncher;
in {
  imports = [];
  options.programs.prismlauncher = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    flatpak = mkOption {
      type = bool;
      default = false;
    };
  };
  config = with lib;
    mkIf cfg.enable {
      services.flatpak = mkIf cfg.flatpak {
        packages = ["org.prismlauncher.PrismLauncher"];
      };

      home.packages = with pkgs;
        mkIf (!cfg.flatpak) [
          prismlauncher
          glfw
        ];
      programs.java = mkIf (!cfg.flatpak) {
        enable = true;
        package = mkDefault pkgs.jdk22;
      };
    };
}
