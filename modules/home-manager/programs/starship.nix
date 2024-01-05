{ inputs, config, lib, pkgs, ...}:

let
  cfg = config.starship;
in 
{
	options.starship = {
		enable = lib.mkEnableOption "Enable module";
		enableZsh = lib.mkEnableOption "Enable Zsh Integration";
		enableBash = lib.mkEnableOption "Enable Bash Integration";
	};
	config = lib.mkIf cfg.enable {
		programs.starship.enable = true;	

		programs.starship.enableZshIntegration = lib.mkIf cfg.enableZsh true;
		programs.starship.enableBashIntegration = lib.mkIf cfg.enableBash true;
	};
}
