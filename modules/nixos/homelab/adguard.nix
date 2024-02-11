{ config, lib, ... }:

let
  cfg = config.homelab.adguard;
in
{
  imports = [ ];
  options.homelab.adguard = with lib; with lib.types; {
    enable = mkEnableOption "";
    extraArgs = mkOption {
      type = listOf str;
      default = [ ];
    };
    domain = mkOption {
      type = str;
      default = "adguard." + config.homelab.domain;
    };
    port = mkOption {
      type = port;
      default = 3010;
    };
    settings = {
      server.domain = mkOption {
        type = str;
        default = cfg.domain;
      };
      server.port = mkOption {
        type = port;
        default = cfg.port;
      };
      server.address = mkOption {
        type = str;
        default = "0.0.0.0";
      };
      dns.rewrites = mkOption {
        type = attrsOf str;
        default = { };
      };
      dns.filters = mkOption {
        type = attrsOf (submodule ({ lib, ... }: {
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
        default = { };
      };
    };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 51820 ];
    };
    services.adguardhome = with builtins; {
      enable = true;
      settings = {
        bind_port = cfg.settings.server.port;
        bind_host = cfg.settings.server.address;
        http = {
          address = "${cfg.settings.server.address}:${toString cfg.settings.server.port}";
        };
        dns.rewrites = (builtins.attrValues (builtins.mapAttrs
          (from: to: {
            domain = from;
            answer = to;
          })
          cfg.settings.dns.rewrites));
        filters = (attrValues (mapAttrs
          (id: list: {
            name = if isNull list.name then id else list.name;
            ID = id;
            url = list.url;
            enabled = list.enabled;
          })
          cfg.settings.dns.filters));
      };
    };
  };
}

