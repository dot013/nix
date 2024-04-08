{
  config,
  lib,
  ...
}: let
  cfg = config.server.jellyseerr;
in {
  imports = [];
  options.server.jellyseerr = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    domain = mkOption {
      type = str;
      default = "jellyseerr." + config.server.domain;
    };
    port = mkOption {
      type = port;
      default = config.server.jellyfin.port + 10;
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
