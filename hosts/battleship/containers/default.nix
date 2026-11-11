{...}: {
  imports = [
    ./garage.nix
    ./nextcloud-capytal.nix
    ./postgresql.nix
  ];

  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = "enp6s0";
    enableIPv6 = true;
  };

  networking.defaultGateway = "192.168.0.101";
}
