{...}: {
  services.caddy.enable = true;
  # services.caddy.package = pkgs-unstable.caddy.withPlugins {
  #   plugins = ["github.com/mholt/caddy-l4@v0.1.2"];
  #   hash = "sha256-orq1LkXp8KeBLsp1eoRQ+dHGeM9t+R47Be58s0/irWI=";
  # };

  networking.firewall.allowedTCPPorts = [80 443 2019 2016];
  networking.firewall.allowedUDPPorts = [80 443 2019 2016];
}
