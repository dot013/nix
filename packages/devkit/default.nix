{
  pkgs,
  pkgs-unstable,
  inputs,
}: rec {
  ghostty = pkgs.callPackage ./ghostty {};
  git = pkgs.callPackage ./git {};
  lazygit = pkgs.callPackage ./lazygit {};
  starship = pkgs.callPackage ./starship {};
  tmux = pkgs.callPackage ./tmux {shell = zsh;};
  yazi = pkgs.callPackage ./yazi {};
  # CURRENTLY BORKED https://github.com/zellij-org/zellij/issues/3970
  zellij = pkgs.callPackage ./zellij {
    shell = zsh;
    zellij = pkgs-unstable.zellij;
  };
  zsh = pkgs.callPackage ./zsh {};
}
