{
  inputs,
  pkgs,
  lib,
}: let
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit lib pkgs;
  };
in {
}
