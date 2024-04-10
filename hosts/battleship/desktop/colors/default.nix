{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.desktop.colors;
in {
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];
  options.desktop.colors = with lib;
  with lib.types; {
    accent = mkOption {
      type = str;
      default = "cdd6f4";
      description = "The accent color of Frappuccino";
    };
    accentBase = mkOption {
      type = str;
      default = "magenta";
      description = "The base name for the accent color to be used in the terminal";
    };
    scheme = mkOption {
      type = path;
      default = ./frappuccino.yaml;
    };
  };
  config = with lib; {
    colorScheme = inputs.nix-colors.lib.schemeFromYAML "frappuccino" (builtins.readFile cfg.scheme);

    home.packages = with pkgs; [
      gnome.gnome-themes-extra
    ];

    gtk = {
      enable = true;
      theme = {
        name = "Catppuccin-Mocha-Compact-Mauve-Dark";
        package = pkgs.catppuccin-gtk.override {
          size = "compact";
          tweaks = ["rimless" "black"];
          accents = ["mauve"];
          variant = "mocha";
        };
      };
    };

    programs.wezterm.config.color_scheme = mkDefault "system";
    programs.wezterm.colorSchemes = mkIf (config.programs.wezterm.config.color_scheme == "system") {
      system = with config.colorScheme.palette; {
        foreground = "#${base05}";
        background = "#${base00}";

        cursor_fg = "#${base01}";
        cursor_bg = "#${cfg.accent}";
        cursor_border = "#${cfg.accent}";

        selection_fg = "#${base04}";
        selection_bg = "#${cfg.accent}";

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
