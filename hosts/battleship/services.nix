{self, ...}: {
  imports = with self.nixosModules.services; [
    adguard
    capytal-gitea
    cloudflared
    minecraft-servers
  ];
}
