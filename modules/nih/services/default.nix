{ config, lib, pkgs, ... }:

{
  imports = [
    ./adguard.nix
    ./caddy.nix
    ./forgejo.nix
    ./tailscale.nix
  ];
  options.nih.services = { };
  config = { };
}
