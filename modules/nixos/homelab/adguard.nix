{ config, lib, pkgs, ... }:

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
    settings = {
      server.domain = mkOption {
        type = str;
        default = "localhost";
      };
      server.port = mkOption {
        type = port;
        default = 3000;
      };
      server.address = mkOption {
        type = str;
        default = "0.0.0.0";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 51820 ];
    };
    services.adguardhome = {
      enable = true;
      settings = {
        bind_port = cfg.settings.server.port;
        bind_host = cfg.settings.server.address;
        http = {
          address = "${cfg.settings.server.address}:${toString cfg.settings.server.port}";
        };
        dns.rewrites = [
          {
            domain = "guz.local";
            answer = "100.66.139.89";
          }
          {
            domain = "*.guz.local";
            answer = "100.66.139.89";
          }
        ];
      };
    };
  };
}

