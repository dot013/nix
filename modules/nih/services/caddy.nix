{
  config,
  lib,
  ...
}: let
  cfg = config.server.caddy;
in {
  imports = [];
  options.server.caddy = with lib; with lib.types; {};
  config = lib.mkIf cfg.enable {};
}
