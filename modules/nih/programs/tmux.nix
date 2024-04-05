{ config, lib, pkgs, ... }:

let
  cfg = config.programs.tmux;
in
{
  imports = [ ];
  options.programs.tmux = with lib; with lib.types; { };
  config = with lib; mkIf cfg.enable { };
}

