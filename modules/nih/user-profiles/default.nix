{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles;
in {
  imports = [
    ./gterminal.nix
  ];
  options.profiles = {};
  config = {};
}
