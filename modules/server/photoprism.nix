{ config, lib, ... }:

let
  cfg = config.server.photoprism;
in
{
  imports = [ ];
  options.server.photoprism = with lib; with lib.types; {
    enable = mkEnableOption "";
    user = mkOption {
      type = str;
      default = "photoprism";
    };
    domain = mkOption {
      type = str;
      default = "photoprism." + config.server.domain;
    };
    port = mkOption {
      type = port;
      default = 2342;
    };
  };
  config = lib.mkIf cfg.enable {
    services.photoprism = {
      enable = true;
      port = cfg.port;
      settings = {
        PHOTOPRISM_HTTP_PORT = cfg.port;
        PHOTOPRISM_SITE_URL = cfg.domain;
        PHOTOPRISM_DISABLE_TLS = true;
        PHOTOPRISM_ADMIN_USER = cfg.user;
        PHOTOPRISM_ADMIN_PASSWORD = cfg.user;
      };
    };
  };
}
