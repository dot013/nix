{...}: {
  imports = [
    ./garage.nix
    ./kitsu.nix
    ./nextcloud-capytal.nix
    ./postgresql.nix
    ./postiz.nix
  ];

  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = "enp6s0";
    enableIPv6 = true;
  };

  networking.networkmanager.unmanaged = ["interface-name:ve-*"];
}
