{
  lib,
  pkgs,
  self,
  ...
}: {
  imports = [
    ./browser.nix
    ./desktop.nix
    ./impermanence.nix
  ];

  home.packages =
    (with pkgs; [
      bitwarden-desktop
      obs-studio
      wezterm
      webcord
    ])
    ++ (with self.packages.${pkgs.stdenv.hostPlatform.system}.devkit; [
      git
      ghostty
      lazygit
      starship
      yazi
      zellij
      zsh
      neovim
    ]);

  home.sessionVariables = {
    EDITOR = "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.devkit.neovim}";
    TERMINAL = "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.devkit.ghostty}";
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
