{ config, lib, pkgs, ... }:

let
  cfg = config.nih.programs;
in
{
  imports = [
    ./hyprland.nix
    ./lf.nix
  ];
  options.programs = { };
  config = { };
}
