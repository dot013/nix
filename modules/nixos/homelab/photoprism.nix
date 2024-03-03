{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.photoprism;
in
{
  imports = [ ];
  options.homelab.photoprism = with lib; with lib.types; {
    enable = mkEnableOption "";
    domain = mkOption {
      type = str;
      default = "photoprism." + config.homelab.domain;
    };
    port = mkOption {
      type = port;
      default = 3040;
    };
  };
  config = lib.mkIf cfg.enable {
    services.photoprism = {
      enable = true;
      port = cfg.port;
    };
  };
}
