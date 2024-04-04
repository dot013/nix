{ config, lib, pkgs, ... }:

{
  imports = [
    ./adguard.nix
    ./caddy.nix
    ./forgejo.nix
  ];
  options.nih.services = { };
  config = { };
}
