{ config, lib, inputs, ... }:

let
  cfg = config.theme;
in 
{
	imports = [
		inputs.nix-colors.homeManagerModules.default
	];
	options.theme = {
		accent = lib.mkOption {
			type = lib.types.str;
			default = "cdd6f4";
			description = "The accent color of Frappuccino";
		};
		accentBase = lib.mkOption {
			type = lib.types.str;
			default = "magenta";
			description = "The base name for the accent color to be used in the terminal";
		};
		scheme = lib.mkOption {
			type = lib.types.path;
			default = ../../themes/frappuccino.yaml;
		};
	};
	config = {
		colorScheme = inputs.nix-colors.lib.schemeFromYAML "frappuccino" (builtins.readFile cfg.scheme);
	};
}
