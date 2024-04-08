{...}: {
  imports = [
    ./adguardhome.nix
    ./forgejo.nix
    ./tailscale.nix
  ];
  options = {};
  config = {};
}
