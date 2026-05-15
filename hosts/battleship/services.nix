{self, ...}: {
  imports = with self.nixosModules.services; [
    minecraft-servers
  ];
}
