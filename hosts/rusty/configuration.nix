{
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../configuration.nix
    ../../home/worm/configuration.nix

    inputs.disko.nixosModules.disko
    ./disks.nix
    ./hardware-configuration.nix
  ];

  users.users."guz" = {
    openssh.authorizedKeys.keyFiles = [
      ../../.ssh/guz-figther.pub
    ];
  };

  # Network
  networking = {
    hostName = lib.mkForce "rusty";
    #wireless.enable = lib.mkForce true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "via"
    ];

  # Laptop features
  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchExternalPower = "lock";

  boot.supportedFilesystems = {
    btrfs = true;
  };
  boot.kernelParams = ["resume_offset=533760"];
  boot.resumeDevice = "/dev/disk/by-label/nixos";

  # HACK: Acer Aspire is a Bitch
  boot.loader.systemd-boot.enable = lib.mkForce true;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
}
