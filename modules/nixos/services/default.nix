{...}: {
  imports = [
    ./adguardhome.nix
    ./forgejo
    ./tailscale.nix
  ];
  options = {};
  config = {};
}
