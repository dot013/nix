{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.starship;
in {
  imports = [];
  options.programs.starship = with lib; with lib.types; {};
  config = with lib;
    mkIf cfg.enable {
      programs.starship = {
        enableFishIntegration = mkDefault config.programs.fish.enable;
        enableIonIntegration = mkDefault config.programs.ion.enable;
        enableNushellIntegration = mkDefault config.programs.nushell.enable;
        enableZshIntegration = mkDefault config.programs.zsh.enable;
      };
    };
}
