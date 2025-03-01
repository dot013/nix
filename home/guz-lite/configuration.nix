{...}: {
  imports = [
    ../worm/configuration.nix
  ];

  home-manager.users.guz = import ./default.nix;

  services.flatpak.enable = true;

  # Xremap run-as-user
  hardware.uinput.enable = true;
  users.groups.uinput.members = ["guz"];
  users.groups.input.members = ["guz"];
}
