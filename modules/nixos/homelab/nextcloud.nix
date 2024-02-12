{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.nextcloud;
in
{
  imports = [ ];
  options.homelab.nextcloud = with lib; with lib.types; {
    enable = mkEnableOption "";
    user = mkOption {
      type = str;
      default = "nextcloud";
    };
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
      default = false;
    };
    settings = {
      admin.user = mkOption {
        type = str;
        default = cfg.user;
      };
      admin.passwordFile = mkOption {
        type = path;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.nextcloud = {
      config = {
        adminuser = cfg.settings.admin.user;
        adminpassFile = toString cfg.settings.admin.passwordFile;
      };
      configureRedis = cfg.configureRedis;
      enable = true;
      home = toString cfg.data.root;
      hostName = cfg.domain;
      https = true;
      package = cfg.package;
      # phpPackage = pkgs.php;
    };
  };
}
