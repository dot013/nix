{ config, pkgs, inputs, ... }:

let
  username = "forgejo";
in
{
  imports = [ ];

  programs.zsh.enable = true;

  services.forgejo = {
    enable = true;
    user = username;
    group = username;
    database = {
      user = username;
      type = "sqlite3";
    };
  };
}
