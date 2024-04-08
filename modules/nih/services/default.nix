{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services;
in {
  imports = [
    ./adguardhome.nix
    ./caddy.nix
    ./tailscale.nix
  ];
  options.services = {};
  config = {};
}
