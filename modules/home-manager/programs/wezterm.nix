{ config, lib, ... }:

let
  cfg = config.wezterm;
in
{
  imports = [ ];
  options.wezterm = with lib; with lib.types; {
    enable = mkEnableOption "Enable Wezterm";
    integration = {
      zsh = mkEnableOption "Enable Zsh Integration";
    };
    colorScheme = mkOption {
      type = str;
      default = "system";
    };
    defaultProg = mkOption {
      default = [ ];
    };
    font = mkOption {
      default = "Fira Code";
      type = str;
    };
    fontSize = mkOption {
      default = 12;
      type = number;
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
        font = wezterm.font("${cfg.font}"),
        font_size = ${toString cfg.fontSize},
        enable_wayland = false, -- TEMPORALLY FIX (see wez/wezterm#4483)
      }
    '';

    programs.wezterm.colorSchemes = {
      system = with config.colorScheme.palette; {
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
