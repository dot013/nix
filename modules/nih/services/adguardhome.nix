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
    nihDomain = mkOption {
      type = str;
      default = "adguard.${config.nih.domains.domain}";
    };
    nihPort = mkOption {
      type = port;
      default = 3053;
    };
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
          enabled = {
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
      networking.firewall = {
        allowedTCPPorts = [53];
        allowedUDPPorts = [53 51820];
      };

      services.adguardhome = {
        settings = {
          bind_port = mkForce cfg.nihPort;
          http = {
            address = "${cfg.settings.bind_host}:${toString cfg.settings.bind_port}";
          };
          dns.rewrites = builtins.attrValues (builtins.mapAttrs
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
