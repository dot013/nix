{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  cfg = config.devkit;

  devkitPkgs = self.packages.${pkgs.system}.devkit;
in {
  imports = [
    inputs.dot013-nvim.homeManagerModules.neovim
  ];
  options.devkit = with lib; {
    enable = mkEnableOption "Enable devkit configuration and packages";

    ghostty.enable = mkOption {
      type = with types; bool;
      default = cfg.enable;
    };
    git.enable = mkOption {
      type = with types; bool;
      default = cfg.enable;
    };
    lazygit.enable = mkOption {
      type = with types; bool;
      default = cfg.enable;
    };
    starship.enable = mkOption {
      type = with types; bool;
      default = cfg.enable;
    };
    yazi.enable = mkOption {
      type = with types; bool;
      default = cfg.enable;
    };
    zellij.enable = mkOption {
      type = with types; bool;
      default = cfg.enable;
    };
    zsh.enable = mkOption {
      type = with types; bool;
      default = cfg.enable;
    };
  };
  config = {
    home.packages = with pkgs; [
      ouch
    ];

    home.sessionVariables = rec {
      # EDITOR = "nvim"; # Default editor, already defined by dot013-nvim
      SHELL = lib.mkIf cfg.zsh "${config.programs.zsh.package}";
      TERM = lib.mkIf cfg.ghostty "${config.programs.ghostty.package}";
      TERMINAL = lib.mkIf cfg.ghostty TERM;
      EXPLORER = lib.mkIf cfg.yazi "${config.programs.yazi.package}";
    };

    # Local development shells
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    # SSH
    programs.ssh.enable = true;
    programs.ssh.matchBlocks = {
      "battleship" = {
        hostname = "battleship";
        user = "${config.home.username}";
        identitiesOnly = true;
        identityFile = "${config.home.homeDirectory}/home/battleship";
        extraOptions = {RequestTTY = "yes";};
      };
      "fithter" = {
        hostname = "fighter";
        user = "${config.home.username}";
        identitiesOnly = true;
        identityFile = "${config.home.homeDirectory}/home/fighter";
        extraOptions = {RequestTTY = "yes";};
      };
    };

    # GPG Keyring
    programs.gpg.enable = true;
    programs.gpg.mutableKeys = true;
    programs.gpg.mutableTrust = true;

    services.gpg-agent.enable = true;
    services.gpg-agent.defaultCacheTtl = 3600 * 24;
    services.gpg-agent.pinentryPackage = pkgs.pinentry-gtk2;

    # Devkit packages

    ## Ghostty (Terminal)
    programs.ghostty = lib.mkIf cfg.ghostty {
      enable = true;
      package = devkitPkgs.ghostty;
    };

    ## Git
    programs.git = lib.mkIf cfg.git {
      enable = true;
      userEmail = "contact@guz.one";
      userName = "Gustavo \"Guz\" L de Mello";
    };

    ## Lazygit (Git TUI)
    programs.lazygit = lib.mkIf cfg.lazygit {
      enable = true;
      package = devkitPkgs.lazygit;
    };

    ## Neovim (Editor)
    ## programs.neovim.enable = true; # Already enabled by dot013-nvim

    ## Starship (Shell decoration)
    programs.starship = lib.mkIf cfg.starship {
      enable = true;
      package = devkitPkgs.starship;
    };

    ## Yazi (File manager)
    programs.yazi = lib.mkIf cfg.yazi {
      enable = true;
      package = devkitPkgs.yazi;
    };

    ## Zellij (Terminal multiplexer)
    programs.zellij = lib.mkIf cfg.zellij {
      enable = true;
      package = devkitPkgs.zellij;
    };

    ## ZSH (Default shell)
    programs.zsh = lib.mkIf cfg.zsh {
      enable = true;
      package = devkitPkgs.zsh;
    };
  };
}
