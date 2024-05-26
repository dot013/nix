{...}: {
  imports = [
    ./adguardhome.nix
    ./forgejo
    ./minecraft-servers.nix
    ./qbittorrent.nix
    ./tailscale.nix
  ];
  options = {};
  config = {};
}
