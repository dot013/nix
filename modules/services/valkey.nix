{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  services.redis.package = pkgs.valkey;
  services.redis.servers."authelia-capytal" = mkIf config.services.authelia.instances."capytal".enable {
    enable = true;
  };
}
