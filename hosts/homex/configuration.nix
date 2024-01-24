# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/systems/set-user.nix
    ../../modules/nixos/config/host.nix
    ./hardware-configuration.nix
    ./network.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.zsh.enable = true;

  set-user.users = [{
    username = "guz";
    shell = pkgs.zsh;
    home = import ./home.nix;
  }];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

}
