{ config, pkgs, ... }:

{
  imports = [ ];
  config = {
    host.networking.hostName = "homex";
    networking = {
      dhcpcd.enable = true;
      interfaces.eno1.ipv4.addresses = [{
        address = "192.168.1.10";
        prefixLength = 28;
      }];
      defaultGateway = "192.168.1.1";
      nameservers = [ "100.100.100.100" "1.1.1.1" "8.8.8.8" ];
    };

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
    systemd.services."tailscaled" = {
      serviceConfig = {
        Environment = [ "TS_PERMIT_CERT_UID=caddy" ];
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts."homex.kiko-liberty.ts.net".extraConfig = ''
        respond "Hello, World"
      '';
      virtualHosts."guz.local".extraConfig = ''
        respond "Hello, World"
      '';
      virtualHosts."adguard.guz.local".extraConfig = ''
        reverse_proxy 192.168.1.10:3010
      '';
    };
    networking.firewall.allowedTCPPorts = [ 80 433 ];

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;


    services.openssh.enable = true;
  };
}



