{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.caddy;
in
{
  imports = [ ];
  options.homelab.caddy = with lib; with lib.types; {
    enable = mkEnableOption "";
    settings = {
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
  };
  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts = cfg.settings.virtualHosts;
    };
  };
}
