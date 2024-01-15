{ config, inputs, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/programs/starship.nix
    ../../modules/home-manager/programs/tmux.nix
    ../../modules/home-manager/programs/wezterm.nix
    ../../modules/home-manager/programs/zsh.nix
  ];
  options.terminal = { };
  config = {
    starship.enable = true;
    starship.enableZsh = true;

    tmux.enable = true;
    tmux.shell = "\${pkgs.zsh}/bin/zsh";

    wezterm.enable = true;
    wezterm.integration.zsh = true;
    wezterm.defaultProg = [
      "zsh"
      "--login"
      "-c"
      "tmux"
      "-f ${config.xdg.configHome}/tmux/tmux.conf"
    ];

    zsh.enable = true;
  };
}
