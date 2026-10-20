{
  config,
  self,
  ...
}: let
  cfg = config.services.clustta;
in {
  imports = [
    self.nixosModules.clustta
  ];

  services.clustta.enable = true;
  services.clustta.settings = {
    host = "localhost";
    private = true;
    secure_cookies = true;
  };

  services.caddy.virtualHosts."clustta.capytal.cc:80".extraConfig = ''
    import capytal-securityheaders
    import capytal-securitytxt

    handle_path /.well-known/security.pub {
      header Content-Type "text/plain"
      root "${./security.pub}"
      file_server
    }

    handle / {
      redir https://clustta.com temporary
    }

    reverse_proxy http://localhost:${toString (cfg.settings.port + 2)} {
      header_up X-Real-Ip {header.Cf-Connecting-Ip}
      header_up X-Forwarded-For {header.Cf-Connecting-Ip}
      header_up X-Forwarded-Proto https
      header_up Host {host}
    }
  '';

  services.anubis.instances."clustta" = {
    policy = {
      useDefaultBotRules = true;
      extraBots = [
        {import = "(data)/common/keep-internet-working.yaml";}
      ];
    };
    settings = {
      BIND = ":${toString (cfg.settings.port + 2)}";
      BIND_NETWORK = "tcp";
      METRICS_BIND = ":${toString (cfg.settings.port + 3)}";
      METRICS_BIND_NETWORK = "tcp";
      SERVE_ROBOTS_TXT = true;
      TARGET = "http://localhost:${toString cfg.settings.port}";
      ED25519_PRIVATE_KEY_HEX_FILE = config.sops.secrets."services/anubis/clustta-private-key".path;
    };
  };

  sops.secrets = {
    # Anubis
    "services/anubis/clustta-private-key" = {owner = config.services.anubis.instances."clustta".user;};
  };
}
