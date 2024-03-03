{ config, lib, pkgs, ... }:

let
  cfg = config.obsidian;
in
{
  imports = [ ];
  options.obsidian = with lib; with lib.types; {
    enable = mkEnableOption "";
  };
  config = lib.mkIf cfg.enable {
    services.flatpak.packages = [
      "md.obsidian.Obsidian"
    ];
  };
}
