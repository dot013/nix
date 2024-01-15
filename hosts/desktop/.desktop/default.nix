{ pkgs, config, ... }:

let
  cfg = config.desktop;
in
{
  imports = [
    ./scripts/desktop.nix
    ./scripts/nixi.nix
    ./scripts/nixx.nix
  ];
  options.desktop = { };
  config = { };
}
