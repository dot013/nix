{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.jellyseerr;
in
{
  imports = [ ];
  options.homelab.jellyseerr = with lib; with lib.types; {
    enable = mkEnableOption "";
    domain = mkOption {
      type = str;
      default = "jellyseerr." + config.homelab.domain;
    };
    port = mkOption {
      type = port;
      default = config.homelab.jellyfin.port + 10;
    };
  };
  config = lib.mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      port = cfg.port;
      openFirewall = true;
    };
  };
}
