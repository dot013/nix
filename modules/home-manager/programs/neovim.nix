{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.neovim;
in {
  imports = [];
  config = with lib;
    mkIf cfg.enable {
      programs.neovim = {
        viAlias = true;
        vimAlias = true;
        withNodeJs = true;
        defaultEditor = true;
      };

      home.sessionVariables = mkIf cfg.defaultEditor {
        EDITOR = "nvim";
      };

      home.packages = with pkgs; [
        git
        lazygit
        gcc
        wget
        alejandra
        stylua
      ];
    };
}
