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

  # Steam (cannot be [properly] installed just in one user)
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];

  # Xbox Controller driver
  hardware.xone.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "megasync"
      "steam"
      "steam-unwrapped"
      "xow_dongle-firmware"
    ];

  # OpenTabletDriver
  hardware.opentabletdriver.enable = true;
  services.udev.extraRules = ''
    KERNEL=="hidraw", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev"
  '';
}
