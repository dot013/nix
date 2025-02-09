{
  inputs,
  pkgs,
  lib,
}: let
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit lib pkgs;
  };

  bitwarden-desktop = import ./bitwarden-desktop.nix {inherit pkgs lib mkNixPak;};
in {
  bitwarden-desktop = bitwarden-desktop.config.script;
  bitwarden-desktop-env = bitwarden-desktop.config.env;
}
