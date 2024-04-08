{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.direnv;
in {
  imports = [];
  options.programs.direnv = with lib; with lib.types; {};
  config = with lib;
    mkIf cfg.enable {
      programs.direnv = {
        enableBashIntegration = mkDefault config.programs.bash.enable;
        enableFishIntegration = mkDefault config.programs.fish.enable;
        enableNushellIntegration = mkDefault config.programs.nushell.enable;
        enableZshIntegration = mkDefault config.programs.zsh.enable;

        nix-direnv.enable = true;
      };
    };
}
