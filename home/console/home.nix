{self, ...}: {
  imports = [
    self.homeManagerModules.features.gnome
    self.homeManagerModules.features.zen-browser
    self.homeManagerModules.features.vesktop

	./impermanence.nix
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
