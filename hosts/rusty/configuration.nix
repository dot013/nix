{
  lib,
  inputs,
  ...
}: {
  imports = [
    ./base.nix

    ../../home/worm/configuration.nix

    inputs.disko-2505.nixosModules.disko
    ./disks.nix
    # ./impermanence.nix

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

  # HACK: Acer Aspire is a Bitch
  boot.loader.systemd-boot.enable = lib.mkForce true;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
}
