{
  config,
  lib,
  ...
}: let
  secrets = config.homelab-secrets.lesser;
  deviceIp = config.services.tailscale.deviceIp;
in {
  imports = [];
  options = {};
  config = {
    services.adguardhome.enable = true;
    services.adguardhome.dns.rewrites = {
      "*.${secrets.homelab-domain}" = deviceIp;
      "${secrets.homelab-domain}" = deviceIp;
    };
    services.adguardhome.openFirewall = true;
    services.adguardhome.port = secrets.services.adguard.port;
    services.adguardhome.dns.filters = {
      "Hagezi's Multi PRO" = {
        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt";
      };
      "Hagezi's Badware Hoster" = {
        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/hoster.txt";
      };
      "Hagezi's DNS Bypass blocking" = {
        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/doh-vpn-proxy-bypass.txt";
      };
      "Hagezi's Dynamic DNS blocking" = {
        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/dyndns.txt";
      };
      "Hagezi's Gambling" = {
        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/gambling.txt";
      };
      "Hagezi's Native - LG webOS" = {
        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/native.lgwebos.txt";
      };
      "Hagezi's Native - Tiktok (Agressive)" = {
        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/native.tiktok.extended.txt";
      };
      "Hagezi's Native - Microsoft/Windows" = {
        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/native.winoffice.txt";
      };
      "Hagezi's Pop-up Ads" = {
        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/popupads.txt";
      };
      "Hagezi's TIF" = {
        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/tif.txt";
      };
    };
    services.adguardhome.settings.user_rules = [
      "@@||tumblr.com^$important"
      "@@||wordpress.com^$important"
      "@@||tailscale.com^$important"
    ];

    services.caddy.enable = true;
    services.caddy.virtualHosts =
      lib.attrsets.mapAttrs'
      (name: service: {
        name = service.domain;
        value = {extraConfig = "reverse_proxy ${deviceIp}:${toString service.port}";};
      })
      secrets.services;
    networking.firewall.allowedTCPPorts = [80 433];

    services.openssh.enable = true;

    services.forgejo = {
      enable = true;
      actions = {
        enable = true;
        token = secrets.services.forgejo.actions-token;
        url = "http://192.168.1.10:${toString secrets.services.forgejo.port}";
        labels = secrets.services.forgejo.actions-labels;
      };
      users = {
        user1 = {
          name = /. + config.sops.secrets."forgejo/user1/name".path;
          password = /. + config.sops.secrets."forgejo/user1/password".path;
          email = /. + config.sops.secrets."forgejo/user1/email".path;
          admin = true;
        };
      };
      settings = {
        server = {
          HTTP_PORT = secrets.services.forgejo.port;
          DOMAIN = secrets.services.forgejo.domain;
          ROOT_URL = "https://${secrets.services.forgejo.domain}";
        };
      };
    };

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      exitNode = true;
      tailnetName = secrets.tailnet-name;
      deviceIp = secrets.device-ip;
    };

    profiles.media-server.enable = true;

    virtualisation = {
      docker.enable = true;
      oci-containers = {
        backend = "docker";
        containers = {
          homarr = {
            image = "ghcr.io/ajnart/homarr:latest";
            autoStart = true;
            ports = ["${toString secrets.services.homarr.port}:7575"];
            volumes = [
              "/var/run/docker.sock:/var/run/docker.sock"
              "/var/lib/homarr/configs:/app/data/configs"
              "/var/lib/homarr/data:/data"
              "/var/lib/homarr/icons:/app/public/icons"
            ];
            environment = {
              NODE_TLS_REJECT_UNAUTHORIZED = "0";
            };
          };
          dashdot = {
            image = "mauricenino/dashdot";
            autoStart = true;
            ports = ["${toString secrets.services.dashdot.port}:3001"];
            extraOptions = ["--privileged"];
            volumes = [
              "/:/mnt/host:ro"
            ];
          };
          muse-discord-bot = {
            image = "codetheweb/muse:latest";
            autoStart = true;
            volumes = [
              "/var/lib/muse/data:/data"
            ];
            environmentFiles = [
              (/. + config.sops.secrets."muse/secrets".path)
            ];
          };
        };
      };
    };
  };
}
