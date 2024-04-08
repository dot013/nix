{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.nih.domains;
in {
  imports = [
    ./tailscale.nix
    ./tailscale-caddy.nix
  ];
  options.nih.domains = with lib;
  with lib.types; {
    enable = mkOption {
      type = bool;
      default = false;
    };
    domain = mkOption {
      type = str;
      default = "${config.nih.name}.local";
    };
    handler = mkOption {
      type = enum ["tailscale" "tailscale-caddy" "adguard" "adguard-caddy"];
      default = "tailscale";
    };
  };
  config = with lib;
    mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = [80 433];
    };
}
