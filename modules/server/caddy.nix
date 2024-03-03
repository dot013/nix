{ config, lib, ... }:

let
  cfg = config.server.caddy;
in
{
  imports = [ ];
  options.server.caddy = with lib; with lib.types; {
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
