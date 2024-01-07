{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ../shared-configuration.nix
  ];

  set-user.users = [
    {
      username = "guz";
      shell = pkgs.zsh;
      home = import ./home.nix;
    }
  ];
}
