{ config, inputs, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/programs/lf.nix
    ../../modules/home-manager/programs/starship.nix
    ../../modules/home-manager/programs/tmux.nix
    ../../modules/home-manager/programs/wezterm.nix
    ../../modules/home-manager/programs/zsh.nix
  ];
  options.terminal = { };
  config = {
    lf.enable = true;

    starship.enable = true;
    starship.enableZsh = true;

    tmux.enable = true;
    tmux.shell = "\${pkgs.zsh}/bin/zsh";

    wezterm.enable = true;
    wezterm.integration.zsh = true;
    wezterm.fontSize = 10;
    wezterm.defaultProg = [
      "zsh"
      "--login"
    ];

    zsh.enable = true;
    zsh.extraConfig.init = ''
      export GPG_TTY=$(tty)

      alias tmux="tmux -f ${config.xdg.configHome}/tmux/tmux.conf"
      alias nvim="${pkgs.steam-run}/bin/steam-run nvim"
    '';
  };
}
