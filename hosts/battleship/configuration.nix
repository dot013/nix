{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./gpu-configuration.nix
    ../../configuration.nix

    ./home.nix
  ];

  users.users."guz" = {
    openssh.authorizedKeys.keyFiles = [
      ../../.ssh/guz-battleship.pub
    ];
  };

  # Network
  networking = {
    hostName = lib.mkForce "battleship";
    #wireless.enable = lib.mkForce true;
  };

  # Xbox Controller driver
  hardware.xone.enable = true;

  hardware.bluetooth.settings.General = {
    experimental = true;

    Privacy = "device";
    JustWorksRepairing = "always";
    Class = "0x000100";
    FastConnectable = true;
  };
  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=Y
  '';

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "megasync"
      "xow_dongle-firmware"
    ];

  # OpenTabletDriver
  hardware.opentabletdriver.enable = true;
  services.udev.extraRules = ''
    KERNEL=="hidraw", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev"
  '';
}
