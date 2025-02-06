{self, ...}: {
  home.username = "guz";
  home.homeDirectory = "/home/guz";

  imports = [
    ../guz-lite

    ./apps.nix
  ];

  # The *state version* indicates which default
  # settings are in effect and will therefore help avoid breaking
  # program configurations. Switching to a higher state version
  # typically requires performing some manual steps, such as data
  # conversion or moving files.
  home.stateVersion = "24.11";
}
