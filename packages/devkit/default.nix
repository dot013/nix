{pkgs}: rec {
  ghostty = pkgs.callPackage ./ghostty {};
  git = pkgs.callPackage ./git {};
  lazygit = pkgs.callPackage ./lazygit {};
  starship = pkgs.callPackage ./starship {};
  yazi = pkgs.callPackage ./yazi {};
}
