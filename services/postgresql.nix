{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.postgresql;
in {
  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql_17;

  services.postgresql.settings = {
    port = 5432;
  };

  services.postgresql.ensureDatabases =
    []
    ++ (optionals config.services.authelia.instances."capytal".enable [
      "authelia-capytal"
    ])
    ++ (optionals config.services.lldap.enable [
      "lldap"
    ]);
  services.postgresql.ensureUsers =
    []
    ++ (optionals config.services.authelia.instances."capytal".enable [
      {
        name = "authelia-capytal";
        ensureDBOwnership = true;
      }
    ])
    ++ (optionals config.services.lldap.enable [
      {
        name = "lldap";
        ensureDBOwnership = true;
      }
    ]);

  services.postgresql.authentication = lib.mkForce ''
    # TYPE  DATABASE        USER            ADDRESS                 METHOD
    local   all             all                                     trust
    host    all             all             127.0.0.1/32            trust
    host    all             all             ::1/128                 trust
  '';
}
