{ config, lib, ... }:

let
  cfg = config.starship;
in
{
  imports = [ ];
  options.starship = with lib; with lib.types; {
    enable = mkEnableOption "Enable module";
    enableZsh = mkEnableOption "Enable Zsh Integration";
    enableBash = mkEnableOption "Enable Bash Integration";
  };
  config = lib.mkIf cfg.enable {
    programs.starship.enable = true;

    programs.starship.enableZshIntegration = lib.mkIf cfg.enableZsh true;
    programs.starship.enableBashIntegration = lib.mkIf cfg.enableBash true;
  };
}
