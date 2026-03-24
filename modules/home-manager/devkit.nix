{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  devkitPkgs = self.packages.${pkgs.stdenv.hostPlatform.system}.devkit;
in {
  # Direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Ghostty
  programs.ghostty.enable = true;
  programs.ghostty.systemd.enable = true;
  programs.ghostty.package = devkitPkgs.ghostty;

  # Git
  programs.git.enable = true;
  programs.git.package = devkitPkgs.git;
  programs.git.lfs.package = devkitPkgs.git;

  # GPG Keyring
  programs.gpg.enable = true;
  programs.gpg.mutableKeys = true;
  programs.gpg.mutableTrust = true;

  # GPG Agent
  services.gpg-agent.enable = true;
  services.gpg-agent.defaultCacheTtl = 3600 * 24;
  services.gpg-agent.pinentry.package = pkgs.pinentry-gtk2;

  # Lazy
  programs.lazygit.enable = true;
  programs.lazygit.package = devkitPkgs.lazygit;

  # Neovim
  neovim.enable = true;

  # SSH
  programs.ssh.enable = true;
  programs.ssh.matchBlocks = {
    "*" = {
      identitiesOnly = true;
      user = "${config.home.username}";
    };
    "spacestation" = {
      hostname = "spacestation";
      identityFile = "${config.home.homeDirectory}/.ssh/spacestation";
    };
    "battleship" = {
      hostname = "battleship";
      identityFile = "${config.home.homeDirectory}/.ssh/battleship";
    };
    "fithter" = {
      hostname = "fighter";
      identityFile = "${config.home.homeDirectory}/.ssh/figther";
    };
  };

  # Starship
  programs.starship.enable = true;
  programs.starship.package = devkitPkgs.starship;

  # Yazi
  programs.yazi.enable = true;
  programs.yazi.package = devkitPkgs.yazi;

  # Zellij
  programs.zellij.enable = true;
  programs.zellij.package = devkitPkgs.zellij;

  ## ZSH
  programs.zsh.enable = true;
  programs.zsh.package = devkitPkgs.zsh;

  home.packages = with pkgs; [
    # TODO: move this to neovim configuration/derivation
    (pkgs.writeShellScriptBin "gvim" ''
      ${lib.getExe config.programs.neovide.package} -- "$@"
    '')
    git-lfs-transfer
  ];

  home.sessionVariables = {
    EXPLORER = "${lib.getExe config.programs.yazi.package}";
    SHELL = "${lib.getExe config.programs.zsh.package}";
    TERM = "xterm-256color";
    TERMINAL = "${lib.getExe config.programs.ghostty.package}";
  };
}
