{
  lib,
  self,
  ...
}: {
  imports = with self.nixosModules.services; [
    adguard
    anubis
    capytal-authelia
    capytal-gitea
    capytal-websites
    # capytal-matrix
    # capytal-xmpp
    cloudflared
    garage
    minecraft-servers
    nextcloud
    postgresql
    valkey
  ];

  services.garage.enable = lib.mkForce false; # Just imported to configure .local domains
}
