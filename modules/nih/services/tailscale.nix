{ config, lib, ... }:

let
  cfg = config.nih.services.tailscale;
in
{
  imports = [ ];
  options.nih.services.tailscale = with lib; with lib.types; {
    enable = mkEnableOption "";
    exitNode = mkOption {
      type = bool;
      default = false;
    };
    port = mkOption {
      type = port;
      default = 41641;
    };
    routingFeatures = mkOption {
      type = enum [ "none" "client" "server" "both" ];
      default = "client";
    };
    tailnetName = mkOption {
      type = nullOr str;
      default = null;
      apply = v:
        if cfg.enable && config.nih.handleDomains && v == null then
          throw "The option ${tailnetName} a is used when Tailscale and Nih's domain handling is enabled, but it is not defined."
        else null;
    };
    upFlags = mkOption {
      type = listOf str;
      default = [ ];
    };
  };
  config = with lib; {
    services.tailscale = {
      enable = true;
      extraUpFlags = cfg.upFlags ++ [
        (if cfg.exitNode then "--advertise-exit-node" else null)
      ];
      port = cfg.port;
      useRoutingFeatures = cfg.routingFeatures;
    };

    nih.networking = mkIf cfg.exitNode {
      portForwarding = mkDefault true;
      nameservers = [ "100.100.100.100" ];
    };
  };
}
