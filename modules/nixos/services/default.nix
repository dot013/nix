{...}: {
  imports = [
    ./adguardhome.nix
    ./forgejo
    ./qbittorrent.nix
    ./tailscale.nix
  ];
  options = {};
  config = {};
}
