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
    tailnetUrl = mkOption {
      type = str;
      default = "${config.services.tailscale.tailnetName}.ts.net";
    };
    deviceUrl = mkOption {
      type = str;
      default = "${config.networking.hostName}.${config.services.tailscale.tailnetUrl}";
    };
    deviceIp = mkOption {
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
          if cfg.exitNode
          then "server"
          else "client"
        );
      };

      systemd.services."tailscaled" = mkIf config.services.caddy.enable (mkDefault {
        serviceConfig = {
          Environment = ["TS_PERMIT_CERT_UID=caddy"];
        };
      });

      boot.kernel.sysctl."net.ipv4.ip_forward" = mkIf cfg.exitNode (mkDefault 1);
      boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = mkIf cfg.exitNode (mkDefault 1);
    };
}
