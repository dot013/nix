{lib, ...}: {
  # Home-manager configurations for when it is used as a NixOS module.

  imports = [
    ../guz-lite/configuration.nix
  ];

  home-manager.users.guz = lib.mkForce import ./default.nix;
}
