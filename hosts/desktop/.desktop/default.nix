{config, ...}: let
  cfg = config.desktop;
in {
  imports = [
    ./scripts/desktop.nix
  ];
  options.desktop = {};
  config = {};
}
