{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.nextcloud;
in
{
  imports = [ ];
  options = with lib; with lib.types; {
    enable = mkEnableOption "";
    package = mkOption {
      type = package;
      default = pkgs.nextcloud28;
    };
    domain = mkOption {
      type = str;
      default = "nextcloud." + config.homelab.domain;
    };
    port = mkOption {
      type = port;
      default = 3030;
    };
    data = {
      root = mkOption {
        type = path;
        default = config.homelab.storage + /nextcloud;
      };
    };
    configureRedis = mkOption {
      type = bool;
      default = true;
    };
  };
  config = lib.mkIf cfg.enable {
    services.nextcloud = {
      configureRedis = cfg.configureRedis;
      enable = true;
      package = cfg.package;
      home = cfg.data.root;
      hostName = cfg.domain;
      https = true;
    };
  };
}
