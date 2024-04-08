{
  config,
  lib,
  ...
}: let
  cfg = config.services.tailscale;
in {
  imports = [];
  options.services.tailscale = with lib;
  with lib.types; {
    exitNode = mkOption {
      type = bool;
      default = false;
    };
    tailnetName = mkOption {
      type = str;
    };
  };
  config = with lib;
    mkIf cfg.enable {
      services.tailscale = {
        extraUpFlags = [
          (
            if cfg.exitNode
            then "--advertise-exit-node"
            else null
          )
          (
            if cfg.exitNode
            then "--exit-node"
            else null
          )
        ];
        useRoutingFeatures = mkDefault (
          if config.nih.type == "server" || cfg.exitNode
          then "server"
          else "client"
        );
      };

      networking.firewall.allowedTCPPorts = [80 433];

      systemd.services."tailscaled" = mkIf config.services.caddy.enable {
        serviceConfig = {
          Environment = ["TS_PERMIT_CERT_UID=caddy"];
        };
      };

      nih.networking = mkIf cfg.exitNode {
        portForwarding = mkDefault true;
        nameservers = ["100.100.100.100"];
      };
    };
}
