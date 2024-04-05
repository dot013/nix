{ config, lib, pkgs, ... }:

let
  cfg = config.programs.zsh;
in
{
  imports = [ ];
  options.programs.zsh = with lib; with lib.types; { };
  config = with lib; mkIf cfg.enable { };
}
