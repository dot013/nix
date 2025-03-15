{lib, ...}: {
  # Home-manager configurations for when it is used as a NixOS module.

  imports = [
    ../guz-lite/configuration.nix
  ];

  home-manager.users.guz = import ./default.nix;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "davinci-resolve"
    ];
}
