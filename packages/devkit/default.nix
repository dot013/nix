{pkgs}: rec {
  ghostty = pkgs.callPackage ./ghostty {};
  git = pkgs.callPackage ./git {};
}
