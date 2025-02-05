{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./gpu-configuration.nix
    ../../configuration.nix
  ];

  users.users."guz" = {
    openssh.authorizedKeys.keyFiles = [
      ../../.ssh/guz-battleship.pub
    ];
  };

  # Network
  networking = {
    hostName = lib.mkForce "figther";
    wireless.enable = lib.mkForce true;
  };
}
