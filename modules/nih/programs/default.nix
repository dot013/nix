{ config, lib, pkgs, ... }:

let
  cfg = config.programs;
in
{
  imports = [
    ./direnv.nix
    ./hyprland.nix
    ./lf.nix
    ./starship.nix
    ./tmux.nix
    ./wezterm.nix
    ./zsh.nix
  ];
  options.programs = { };
  config = { };
}
