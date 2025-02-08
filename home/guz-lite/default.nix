{self, ...}: {
  home.username = "guz";
  home.homeDirectory = "/home/guz";

  imports = [
    self.homeManagerModules.devenv
    self.homeManagerModules.zen-browser

    ./apps.nix
    ./style.nix
    ./desktop.nix
    ./keymaps.nix
  ];

  # The *state version* indicates which default
  # settings are in effect and will therefore help avoid breaking
  # program configurations. Switching to a higher state version
  # typically requires performing some manual steps, such as data
  # conversion or moving files.
  home.stateVersion = "24.11";
}
