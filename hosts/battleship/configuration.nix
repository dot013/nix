{
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
with lib; {
  imports = [
    ../../secrets.nix

    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-gpu.nix
    ./hardware-configuration.nix

    self.nixosModules.features.devkit
    self.nixosModules.features.fonts
    self.nixosModules.features.locale-brazil
    self.nixosModules.features.preservation
    self.nixosModules.features.qmk-keyboard
    self.nixosModules.features.tailscale

    # Services
    self.nixosModules.services.adguard
    self.nixosModules.services.anubis
    self.nixosModules.services.capytal-authelia
    self.nixosModules.services.capytal-gitea
    self.nixosModules.services.capytal-websites
    self.nixosModules.services.cloudflared
    self.nixosModules.services.garage
    self.nixosModules.services.minecraft-servers
    self.nixosModules.services.nextcloud
    self.nixosModules.services.postgresql
    self.nixosModules.services.valkey
  ];

  services.garage.enable = mkForce false; # Just imported to configure .local domains

  # Home Manager
  home-manager.users."guz" = {...}: {
    imports = [self.homeManagerModules.features.devkit];

    home.stateVersion = "25.11";
  };
  # Users
  users.users."guz" = {
    extraGroups = ["wheel" "guz"];
    isNormalUser = true;
    password = "1313";
    # hashedPasswordFile = builtins.toString config.sops.secrets."guz/password".path;
    shell = self.packages.${pkgs.stdenv.hostPlatform.system}.devkit.zsh;
    openssh.authorizedKeys.keyFiles = [../../.ssh/battleship.pub];
  };
  users.groups."guz" = {};

  # Yet another nix cli helper
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 3";
    flake = "/home/guz/Projects/dot013-nix";
  };

  # Networking
  networking.hostName = "battleship";
  networking.networkmanager.enable = true;

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [53];
  networking.firewall.allowedTCPPorts = [80 433];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
