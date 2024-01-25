{ config, pkgs, lib, ... }:

let
  cfg = config.homelab;
  homelab = pkgs.writeShellScriptBin "homelab" ''
    command="$1";

    flakeDir="${toString cfg.flakeDir}";

    if [[ "$command" == "build" ]]; then
      shift 1;
      sudo nixos-rebuild switch --flake "$flakeDir" "$@"
    fi
  '';
in
{
  imports = [
  ];
  options.homelab = with lib; with lib.types; {
    enable = mkEnableOption "";
    flakeDir = mkOption {
      type = str;
    };
    storage = mkOption {
      type = path;
      default = /data/homelab;
      description = "The Homelab central storage path";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      homelab
    ];
  };
}
