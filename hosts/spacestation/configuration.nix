{
  config,
  inputs,
  pkgs,
  self,
  ...
}: {
  imports = [
    ../../secrets.nix

    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix

    self.nixosModules.features.devkit
    self.nixosModules.features.fonts
    self.nixosModules.features.locale-brazil
    self.nixosModules.features.preservation
    self.nixosModules.features.qmk-keyboard
    self.nixosModules.features.tailscale

    # Services
    self.nixosModules.services.garage
  ];

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
    openssh.authorizedKeys.keyFiles = [../../.ssh/spacestation.pub];
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
  networking.hostName = "spacestation";
  networking.networkmanager.enable = true;
  networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);

  # Firewall
  networking.firewall.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.mirroredBoots = [
    {
      devices = ["nodev"];
      path = "/boot";
      efiSysMountPoint = "/boot";
    }
    {
      devices = ["nodev"];
      path = "/boot-fallback";
      efiSysMountPoint = "/boot-fallback";
    }
  ];
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.initrd.systemd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
