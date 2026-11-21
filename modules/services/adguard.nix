{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.services.adguardhome;
  simplifyDomain = domain:
    pipe domain [
      (removePrefix "https://")
      (removePrefix "http://")
      (splitString ":")
      (p: elemAt p 0)
    ];
  isLocalDomain = domain: (hasSuffix ".local" (simplifyDomain domain));
in {
  services.adguardhome = rec {
    enable = true;
    openFirewall = true;
    port = 8753;
    mutableSettings = false;
    settings = {
      http = {address = "127.0.0.1:${toString port}";};
      users = mapAttrsToList (name: password: {inherit name password;}) {
        "admin" = "aUUNsJ8q92A0GsOhLgkP2CyAhC4Tc6KSLAxk.S5BLhKGlm";
      };
      theme = "dark";
      dns = {
        bootstrap_dns = [
          "1.1.1.1"
          "8.8.8.8"
          "9.9.9.9"
        ];
        bind_hosts = [
          "0.0.0.0"
        ];
        upstream_dns = [
          "9.9.9.9"
        ];
        fallback_dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
      filtering = {
        rewrites = mkIf config.services.caddy.enable (pipe config.services.caddy.virtualHosts [
          (filterAttrs (_: v: isLocalDomain v.hostName))
          (mapAttrsToList (_: v: {
            domain = simplifyDomain v.hostName;
            answer = "100.98.115.36";
            enabled = true;
          }))
        ]);
        parental_enabled = false;
        protection_enabled = true;
        filtering_enabled = true;
        safe_search.enabled = false;
        safebrowsing_enabled = false;
      };
      filters =
        imap (id: url: {
          enabled = true;
          inherit id url;
        }) [
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt"
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/hoster.txt"
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/doh-vpn-proxy-bypass.txt"
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/dyndns.txt"
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/gambling.txt"
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/native.lgwebos.txt"
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/native.tiktok.extended.txt"
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/native.winoffice.txt"
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/popupads.txt"
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/tif.txt"
        ];
      user_rules = [
        "@@||bearblog.dev^$important"
        "@@||blogspot.com^$important"
        "@@||neocities.org^$important"
        "@@||tailscale.com^$important"
        "@@||torproject.org^$important"
        "@@||tumblr.com^$important"
        "@@||wordpress.com^$important"
      ];
    };
  };

  services.caddy.virtualHosts."adguard.local:80".extraConfig = ''
    reverse_proxy http://localhost:${toString cfg.port}
  '';

  # Ports needed to access the DNS resolver
  networking.firewall.allowedTCPPorts = [53 80];
  networking.firewall.allowedUDPPorts = [53 80 51820];
}
