{self, ...}: {
  imports = with self.nixosModules.services; [
    capytal-gitea
    cloudflared
    minecraft-servers
  ];
}
