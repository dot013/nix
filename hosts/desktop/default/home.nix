{ config, pkgs, inputs, ... }:

{
  imports = [
    ../shared-home.nix
  ];
  librewolf.profiles.guz.isDefault = true;

  services.flatpak.packages = [
    "com.valvesoftware.Steam"
  ];
}
