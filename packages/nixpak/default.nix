{
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit lib pkgs;
  };

  bitwarden-desktop = import ./bitwarden-desktop.nix {inherit lib mkNixPak pkgs self;};
  zen = import ./zen-browser.nix {inherit lib mkNixPak pkgs self;};
  brave = import ./brave.nix {inherit lib mkNixPak pkgs self;};
in {
  bitwarden-desktop = bitwarden-desktop.config.script;
  bitwarden-desktop-env = bitwarden-desktop.config.env;

  # Currently borked: "Filed to create a ProcessSingleton for your profile directory"
  # brave = brave.config.script;
  # brave-env = brave.config.env;

  zen-browser = zen.config.script;
  zen-browser-env = zen.config.env;
}
