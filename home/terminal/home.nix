{
  lib,
  pkgs,
  self,
  ...
}: {
  imports = [
    self.homeManagerModules.devkit

    ./browser.nix
    ./desktop.nix
    ./impermanence.nix
  ];

  home.packages =
    # Programs
    (with pkgs; [
      self.packages.${pkgs.stdenv.hostPlatform.system}.audacity
      bitwarden-desktop
      obs-studio
      wezterm
      webcord
    ])
    ]);

  };

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
