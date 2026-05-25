{
  config,
  inputs,
  self,
  ...
}: {
  imports =
    [
      inputs.guzone.nixosModules.guzone
    ]
    ++ (with self.nixosModules.services; [
      adguard
      capytal-gitea
      cloudflared
      minecraft-servers
      nextcloud
    ]);

  services.guzone.enable = true;
  services.guzone.port = 9001;

  services.caddy.virtualHosts = {
    "guz.one:80".extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.guzone.port} {
        header_up X-Real-Ip {header.Cf-Connecting-Ip}
        header_up X-Forwarded-For {header.Cf-Connecting-Ip}
        header_up X-Forwarded-Proto https
        header_up Host {host}
      }
    '';
  };
}
