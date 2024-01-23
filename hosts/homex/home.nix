{ config, pkgs, inputs, ... }:


{
  imports = [
    ../../modules/home-manager/programs/starship.nix
    ../../modules/home-manager/programs/tmux.nix
    ../../modules/home-manager/programs/zsh.nix
  ];

  starship.enable = true;
  starship.enableZsh = true;

  tmux.enable = true;
  tmux.shell = "\${pkgs.zsh}/bin/zsh";

  zsh.enable = true;
  zsh.extraConfig.init = ''
    export GPG_TTY=$(tty)
  '';
}
