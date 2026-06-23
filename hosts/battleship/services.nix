{
  config,
  lib,
  inputs,
  self,
  ...
}: {
  imports =
    [
      inputs.guzone.nixosModules.guzone
      inputs.keikos.nixosModules.keikos
    ]
    ++ (with self.nixosModules.services; [
      adguard
      capytal-gitea
      cloudflared
      garage
      minecraft-servers
      nextcloud
    ]);

  services.garage.enable = lib.mkForce false; # Just imported to configure .local domains

  services.guzone.enable = true;
  services.guzone.port = 9001;

  services.keikos.web.enable = true;
  services.keikos.web.port = 9002;
  services.keikos.web.envFile = config.sops.secrets."services/keiko/env-file".path;

  services.caddy.virtualHosts = {
    "guz.one:80".extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.guzone.port} {
        header_up X-Real-Ip {header.Cf-Connecting-Ip}
        header_up X-Forwarded-For {header.Cf-Connecting-Ip}
        header_up X-Forwarded-Proto https
        header_up Host {host}
      }
    '';
    "keikos.work:80".extraConfig = ''
      redir https://kois.work{uri} permanent
    '';
    "kois.work:80".extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.keikos.web.port} {
        header_up X-Real-Ip {header.Cf-Connecting-Ip}
        header_up X-Forwarded-For {header.Cf-Connecting-Ip}
        header_up X-Forwarded-Proto https
        header_up Host {host}
      }
    '';
  };

  sops.secrets = {
    "services/keiko/env-file" = {owner = config.services.keikos.web.user;};
  };
}
