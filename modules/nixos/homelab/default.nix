{ config, pkgs, lib, ... }:

let
  cfg = config.homelab;
  homelab = pkgs.writeShellScriptBin "homelab" ''
    gum="${pkgs.gum}/bin/gum";
    flakeDir="${toString cfg.flakeDir}";

    command="$1";

    if [[ "$command" == "build" ]]; then
      shift 1;
      sudo nixos-rebuild switch --flake "$flakeDir" "$@"
    fi

    ${if cfg.forgejo.cliAlias then ''
      if [[ "$command" == "forgejo" ]]; then
        shift 1;
        sudo --user=${cfg.forgejo.user} ${cfg.forgejo.package}/bin/gitea --work-path ${cfg.forgejo.data.root} "$@"
      fi
    '' else ""}
  '';
in
{
  imports = [
    ./forgejo.nix
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
