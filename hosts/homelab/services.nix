{
  config,
  lib,
  pkgs,
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
    services.adguardhome.settings.bind_port = secrets.services.adguard.port;

    services.caddy.enable = true;
    services.caddy.virtualHosts =
      lib.attrsets.mapAttrs'
      (name: service: {
        name = service.domain;
        value = {extraConfig = "reverse_proxy ${deviceIp}:${toString service.port}";};
      })
      secrets.services;
    networking.firewall.allowedTCPPorts = [80 433];

    services.forgejo = {
      enable = true;
      actions = {
        enable = true;
        token = secrets.services.forgejo.actions-token;
        url = "http://${config.services.tailscale.deviceUrl}:${toString secrets.services.forgejo.port}";
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
          ROOT_URL = "https://${secrets.services.forgejo.domain}";
          DOMAIN = "${secrets.services.forgejo.domain}";
        };
      };
    };

    services.openssh.enable = true;

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      exitNode = true;
      tailnetName = secrets.tailnet-name;
      deviceIp = secrets.device-ip;
    };
  };
}
