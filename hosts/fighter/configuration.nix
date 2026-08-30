{
  inputs,
  lib,
  pkgs,
  self,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix

    self.nixosModules.features.devkit
    self.nixosModules.features.flatpak
    self.nixosModules.features.fonts
    self.nixosModules.features.gnome
    self.nixosModules.features.locale-brazil
    self.nixosModules.features.plymouth
    self.nixosModules.features.preservation
    self.nixosModules.features.qmk-keyboard
    self.nixosModules.features.sddm
    self.nixosModules.features.tailscale

    ./hardware-configuration.nix
  ];

  # Home Manager
  home-manager.users."guz" = {...}: {
    imports = [
      self.homeManagerModules.features.devkit
      self.homeManagerModules.features.flatpak
      self.homeManagerModules.features.gnome
      self.homeManagerModules.features.zen-browser
      self.homeManagerModules.features.vesktop
      self.homeManagerModules.features.vivaldi
    ];

    home.stateVersion = "25.11";
  };

  nix.allowUnfreeList = ["vivaldi"];

  # Users
  users.users."guz" = {
    extraGroups = ["wheel" "guz"];
    isNormalUser = true;
    password = "1313";
    # hashedPasswordFile = builtins.toString config.sops.secrets."guz/password".path;
    shell = self.packages.${pkgs.stdenv.hostPlatform.system}.devkit.zsh;
  };
  users.groups."guz" = {};

  # NH
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 3";
    flake = "/home/guz/Projects/dot013-nix";
  };

  # Network
  networking.networkmanager.enable = true;
  networking.hostName = "fighter";

  ## Firewall
  networking.firewall.enable = true;

  # Bootloader
  boot.loader.grub.enable = lib.mkForce true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enableCryptodisk = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
