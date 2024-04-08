{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  tailnetName = config.services.tailscale.tailnetName;
  ip = config.nih.ip;
  domain = config.nih.domains.domain;
  listHas = item: list: (lib.lists.count (x: x == item) list) > 0;
  servicesList = filterAttrs (n: v: (listHas n ["adguardhome" "caddy" "tailscale"])) config.services;
  servicesWithDomain = filterAttrs (n: v: isAttrs v && v ? nihDomain && v ? nihPort) servicesList;
in {
  imports = [];
  config = with lib;
    mkIf (config.nih.domains.enable && config.nih.domains.handler == "tailscale-caddy") {
      services.tailscale = {
        enable = mkForce true;
        useRoutingFeatures = mkForce "both";
      };

      services.adguardhome = {
        enable = mkForce true;
        dns.rewrites = {
          "*.homelab.local" = "192.168.1.10";
          "homelab.local" = "192.168.1.10";
        };
      };

      services.caddy = {
        enable = mkForce true;
        virtualHosts."homelab.kiko-liberty.ts.net" = {
          extraConfig = ''
            reverse_proxy 192.168.1.10:4040
          '';
        };
        /*
        virtualHosts = mapAttrs'
          (n: v: nameValuePair (v.nihDomain) ({
            extraConfig = ''
              reverse_proxy 100.66.139.89:${toString v.nihPort}
            '';
          }))
          servicesWithDomain;
        */
      };
    };
}
