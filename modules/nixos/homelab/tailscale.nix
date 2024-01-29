{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.tailscale;
in
{
  imports = [
    ./network.nix
  ];
  options.homelab.tailscale = with lib; with lib.types; {
    enable = mkEnableOption "";
    mode = mkOption {
      type = enum [
        "client"
        "server"
        "both"
      ];
      default = "both";
    };
    exitNode = mkOption {
      type = bool;
      default = false;
    };
    settings = { };
  };
  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = cfg.mode;
    };

    homelab.network = lib.mkIf cfg.exitNode { portForwarding = lib.mkDefault true; };

  };
}

