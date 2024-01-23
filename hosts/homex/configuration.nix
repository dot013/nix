# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/systems/set-user.nix
    ../../modules/nixos/config/host.nix
    ./hardware-configuration.nix
  ];

  host.networking.hostName = "homex";
  networking = {
    dhcpcd.enable = true;
    interfaces.eno1.ipv4.addresses = [{
      address = "192.168.1.10";
      prefixLength = 28;
    }];
    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  set-user.users = [{
    username = "guz";
    shell = pkgs.zsh;
    home = import ./home.nix;
  }];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

}
