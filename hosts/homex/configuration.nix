# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/systems/set-user.nix
    ../../modules/nixos/config/host.nix
    ../../modules/nixos/homelab
    ./hardware-configuration.nix
    ./network.nix
    ./secrets.nix
    ./users
  ];

  homelab = {
    enable = true;
    flakeDir = "/home/guz/.nix#homex";

    forgejo = {
      enable = true;
      settings.users."user1" = {
        name = /. + config.sops.secrets."forgejo/user1/name".path;
        email = /. + config.sops.secrets."forgejo/user1/email".path;
        password = /. + config.sops.secrets."forgejo/user1/password".path;
        admin = true;
      };
    };
  };

  services.tailscale.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

}

