{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.steam;
in {
  imports = [];
  options.programs.steam = with lib;
  with lib.types; {
    wayland = mkOption {
      type = bool;
      default = config.programs.hyprland.enable;
    };
  };
  config = with lib;
    mkIf cfg.enable {
      environment.systemPackages = with pkgs; [steam-run];

      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "steam"
          "steam-original"
          "steam-run"
        ];

      programs.steam = {
        gamescopeSession = mkIf cfg.wayland {
          enable = true;
        };
      };
    };
}
