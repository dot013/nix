{ config, lib, pkgs, ... }:

let
  cfg = config.nih.services.caddy;
in
{
  imports = [ ];
  options.nih.services.caddy = with lib; with lib.types; {
    enable = mkEnableOption "";
    virtualHosts = mkOption {
      type = attrsOf (submodule ({ config, lib, ... }: {
        options = {
          extraConfig = mkOption {
            type = lines;
            default = "";
          };
        };
      }));
      default = { };
    };
  };
  config = with lib; mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts = cfg.virtualHosts;
    };
  };
}
