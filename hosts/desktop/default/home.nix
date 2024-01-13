{ config, pkgs, inputs, ... }:

{
  imports = [
    ../shared-home.nix
  ];
  librewolf.profiles.guz.isDefault = true;
}
