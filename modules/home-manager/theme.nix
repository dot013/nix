{ config, lib, inputs, pkgs, ... }:

let
  cfg = config.theme;
in
{
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];
  options.theme = with lib; with lib.types; {
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
      default = ../../themes/frappuccino.yaml;
    };
  };
  config = {
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
          tweaks = [ "rimless" "black" ];
          accents = [ "mauve" ];
          variant = "mocha";
        };
      };
    };
  };
}
