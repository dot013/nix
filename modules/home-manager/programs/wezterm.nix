{ inputs, pkgs, lib, config, ... }:

let
	cfg = config.wezterm;
in
{
	options.wezterm = {
		enable = lib.mkEnableOption "Enable Wezterm";
		integration = {
			zsh = lib.mkEnableOption "Enable Zsh Integration";
		};
		colorScheme = lib.mkOption {
			type = lib.types.str;
			default = "system";
		};
		defaultProg = lib.mkOption {
			default = [];
		};
	};
	config = lib.mkIf cfg.enable {
		programs.wezterm.enable = true;
		programs.wezterm.enableZshIntegration = lib.mkIf (cfg.integration.zsh) true;

		programs.wezterm.extraConfig = ''
			return {
				enable_tab_bar = false;
				color_scheme = "${cfg.colorScheme}",
				default_prog = { ${lib.concatMapStrings (x: "'" + x + "',") cfg.defaultProg} },
			}
		'';

		programs.wezterm.colorSchemes = { 
			system = with config.colorScheme.colors; {
				foreground = "#${base05}";
				background = "#${base00}";

				cursor_fg = "#${base01}";
				cursor_bg = "#${config.theme.accent}";
				cursor_border = "#${config.theme.accent}";

				selection_fg = "#${base04}";
				selection_bg = "#${config.theme.accent}";

				split = "#${base04}";

				ansi = [
					"#${base03}"
					"#${base08}"
					"#${base0B}"
					"#${base0A}"
					"#${base0D}"
					"#${base0E}"
					"#${base0C}"
					"#${base03}"
				];

				brights = [
					"#${base03}"
					"#${base08}"
					"#${base0B}"
					"#${base0A}"
					"#${base0D}"
					"#${base0E}"
					"#${base0C}"
					"#${base03}"
				];
			};
		};
	};
}
