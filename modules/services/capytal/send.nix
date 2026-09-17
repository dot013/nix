{config, ...}: let
  cfg = config.services.send;
in {
  services.send = {
    enable = true;
    baseUrl = "send.capytal.cc";
    redis.createLocally = true;
  };

  services.anubis.instances."send" = {
    settings = {
      BIND = ":${toString (cfg.port + 2)}";
      BIND_NETWORK = "tcp";
      METRICS_BIND = ":${toString (cfg.port + 3)}";
      METRICS_BIND_NETWORK = "tcp";
      SERVE_ROBOTS_TXT = true;
      TARGET = "http://localhost:${toString cfg.port}";
      ED25519_PRIVATE_KEY_HEX_FILE = config.sops.secrets."services/anubis/send-private-key".path;
    };
  };

  services.caddy.virtualHosts."send.capytal.cc:80".extraConfig = ''
    import capytal-securitytxt
    import capytal-securityheaders

    log {
      level DEBUG
    }
    reverse_proxy :${toString (cfg.port + 2)} {
      # header_up X-Real-Ip {header.Cf-Connecting-Ip}
      # header_up X-Forwarded-For {header.Cf-Connecting-Ip}
      header_up X-Forwarded-Proto https
      header_up X-Http-Version {http.request.proto}
      header_up Host {host}
    }
  '';

  sops.secrets = {
    "services/anubis/send-private-key" = {owner = config.services.anubis.instances."send".user;};
  };
}
