{ config, lib, pkgs, ... }:

let
  cfg = config.nih.networking.tailscale;
in
{
  imports = [ ];
  options.nih.networking.tailscale = with lib; with lib.types; {
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
    };
  };
}
