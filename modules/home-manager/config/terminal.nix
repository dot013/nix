{ config, inputs, pkgs, ... }:

{
  imports = [
    ../programs/starship.nix
    ../programs/tmux.nix
    ../programs/wezterm.nix
    ../programs/zsh.nix
  ];
  options = { };
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
    ];

    zsh.enable = true;
  };
}
