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

    ./services.nix
  ];

  users.users."guz" = {
    openssh.authorizedKeys.keyFiles = [
      ../../.ssh/guz-battleship.pub
    ];
  };

  # Network
  networking = {
    hostName = lib.mkForce "battleship";
    # nameservers = ["192.168.0.110"];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
