{
  config,
  lib,
  ...
}: let
  cfg = config.services.adguardhome;
in {
  imports = [];
  options.services.adguardhome = with lib;
  with lib.types; {
    dns.filters = mkOption {
      type = attrsOf (submodule ({lib, ...}: {
        options = {
          name = mkOption {
            type = nullOr str;
            default = null;
          };
          url = mkOption {
            type = str;
          };
          enabled = mkOption {
            type = bool;
            default = true;
          };
        };
      }));
      default = {};
    };
    dns.rewrites = mkOption {
      type = attrsOf str;
      default = {};
    };
  };
  config = with lib;
    mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = [53];
      networking.firewall.allowedUDPPorts = [53 51820];

      services.adguardhome = {
        settings = {
          filtering.rewrites = builtins.attrValues (builtins.mapAttrs
            (from: to: {
              domain = from;
              answer = to;
            })
            cfg.dns.rewrites);
          filters = attrValues (mapAttrs
            (id: list: {
              name =
                if isNull list.name
                then id
                else list.name;
              ID = id;
              url = list.url;
              enabled = list.enabled;
            })
            cfg.dns.filters);
        };
      };
    };
}
