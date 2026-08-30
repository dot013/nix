{
  pkgs,
  wrapPackage,
  # Package
  starship ? pkgs.starship,
}:
wrapPackage {
  inherit pkgs;
  package = starship;
  env.STARSHIP_CONFIG = ./config.toml;
}
