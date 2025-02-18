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
    tmux.enable = mkOption {
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
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ouch
    ];

    home.sessionVariables = {
      # EDITOR = "nvim"; # Default editor, already defined by dot013-nvim
      SHELL = lib.mkIf cfg.zsh.enable "${lib.getExe config.programs.zsh.package}";
      TERM = lib.mkIf cfg.ghostty.enable "xterm-ghostty";
      TERMINAL = lib.mkIf cfg.ghostty.enable "${lib.getExe config.programs.ghostty.package}";
      EXPLORER = lib.mkIf cfg.yazi.enable "${lib.getExe config.programs.yazi.package}";
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
    programs.ghostty = lib.mkIf cfg.ghostty.enable {
      enable = true;
      package = devkitPkgs.ghostty;
      # package = pkgs.ghostty;
    };

    ## Git
    programs.git = lib.mkIf cfg.git.enable {
      enable = true;
      userEmail = "contact@guz.one";
      userName = "Gustavo \"Guz\" L de Mello";
      package = devkitPkgs.git;
    };

    ## Lazygit (Git TUI)
    programs.lazygit = lib.mkIf cfg.lazygit.enable {
      enable = true;
      package = devkitPkgs.lazygit;
      # package = pkgs.lazygit;
    };

    ## Neovim (Editor)
    ## programs.neovim.enable = true; # Already enabled by dot013-nvim

    ## Starship (Shell decoration)
    programs.starship = lib.mkIf cfg.starship.enable {
      enable = true;
      package = devkitPkgs.starship;
      # package = pkgs.starship;
    };

    ## Yazi (File manager)
    programs.yazi = lib.mkIf cfg.yazi.enable {
      enable = true;
      package = devkitPkgs.yazi;
      # package = pkgs.yazi;
    };

    ## Zellij (Terminal multiplexer)
    #
    # CURRENTLY BORKED https://github.com/zellij-org/zellij/issues/3970
    #
    # programs.zellij = lib.mkIf cfg.zellij.enable {
    #   enable = true;
    #   package = devkitPkgs.zellij;
    #   # package = pkgs.zellij;
    # };

    ## Tmux (Backup terminal multiplexer)
    programs.tmux = lib.mkIf cfg.tmux.enable {
      enable = true;
      package = devkitPkgs.tmux;
      # baseIndex = 1;
      # keyMode = "vi";
      # mouse = true;
      # prefix = "Ctrl-G";
      # shell = lib.getExe config.programs.zsh.package;
      # terminal = "screen-256color";
      # plugins = with pkgs; [
      #   {
      #     plugin = tmuxPlugins.catppuccin.overrideAttrs (_: {
      #       src = fetchFromGitHub {
      #         owner = "guz013";
      #         repo = "frappuccino-tmux";
      #         rev = "4255b0a769cc6f35e12595fe5a33273a247630aa";
      #         sha256 = "0k8yprhx5cd8v1ddpcr0dkssspc17lq2a51qniwafkkzxi3kz3i5";
      #       };
      #     });
      #   }
      #   {plugin = tmuxPlugins.better-mouse-mode;}
      #   {
      #     plugin = tmuxPlugins.mkTmuxPlugin {
      #       pluginName = "tmux.nvim";
      #       version = "unstable-2024-04-05";
      #       src = fetchFromGitHub {
      #         owner = "aserowy";
      #         repo = "tmux.nvim";
      #         rev = "63e9c5e054099dd30af306bd8ceaa2f1086e1b07";
      #         sha256 = "0ynzljwq6hv7415p7pr0aqx8kycp84p3p3dy4jcx61dxfgdpgc4c";
      #       };
      #     };
      #   }
      #   {plugin = tmuxPlugins.resurrect;}
      #   {plugin = tmuxPlugins.continuum;}
      # ];
    };

    ## ZSH (Default shell)
    programs.zsh = lib.mkIf cfg.zsh.enable {
      enable = true;
      package = devkitPkgs.zsh;
      # package = pkgs.zsh;
    };
  };
}
