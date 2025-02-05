{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.dot013-nvim.homeManagerModules.neovim
  ];

  home.sessionVariables = {
    # EDITOR = "nvim"; # Default editor, already defined by dot013-nvim
    SHELL = lib.getExe config.programs.zsh.package;
    TERMINAL = lib.getExe config.programs.ghostty.package;
  };

  # Local development shells
  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;

  # Ghostty (Terminal)
  programs.ghostty.enable = true;
  programs.ghostty.enableZshIntegration = true;

  # Neovim (Editor)
  # programs.neovim.enable = true; # Already enabled by dot013-nvim

  # Git
  programs.git.enable = true;
  programs.git.userEmail = "contact@guz.one";
  programs.git.userName = "Gustavo \"Guz\" L de Mello";
  programs.git.extraConfig = {
    credential.helper = "store";
    http.proxy = "";
    https.proxy = "";
    signing.singByDefault = true;
  };

  # Better git diff
  programs.git.delta.enable = true;

  # GPG Keyring
  programs.gpg.enable = true;
  programs.gpg.mutableKeys = true;
  programs.gpg.mutableTrust = true;

  services.gpg-agent.enable = true;
  services.gpg-agent.enableZshIntegration = true;
  services.gpg-agent.defaultCacheTtl = 3600 * 24;
  services.gpg-agent.pinentryPackage = pkgs.pinentry-gtk2;

  # Git TUI
  programs.lazygit.enable = true;
  programs.lazygit.settings = {
    git.paging.colorArg = "always";
    git.paging.pager = "${lib.getExe config.programs.git.delta.package} --dark --paging=never";
  };

  # Shell decoration
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;

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

  # Yazi (File manager)
  programs.yazi.enable = true;
  programs.yazi.enableZshIntegration = true;

  # Zellij (Terminal multiplexer)
  programs.zellij.enable = true;
  programs.zellij.enableZshIntegration = true;

  # Default shell
  programs.zsh.enable = true;
  programs.zsh.autosuggestion.enable = true;
  programs.zsh.enableCompletion = true;
}
