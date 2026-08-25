{
  config,
  lib,
  inputs,
  ...
}:
with lib; {
  imports = [
    inputs.capytalcc.nixosModules.capytalcc
    inputs.guzone.nixosModules.guzone
    inputs.keikos.nixosModules.keikos
  ];

  services.capytalcc.web.enable = true;
  services.capytalcc.web.port = 7332;

  services.guzone.enable = true;
  services.guzone.port = 9001;

  services.keikos.web.enable = true;
  services.keikos.web.port = 9002;
  services.keikos.web.envFile = config.sops.secrets."services/keiko/env-file".path;

  services.caddy = {
    virtualHosts = {
      "capytal.cc:80".extraConfig = ''
        import capytal-securitytxt

        handle_path /.well-known/security.pub {
          header Content-Type "text/plain"
          root "${./security.pub}"
          file_server
        }

        reverse_proxy http://localhost:${toString config.services.capytalcc.web.port} {
          header_up X-Real-Ip {header.Cf-Connecting-Ip}
          header_up X-Forwarded-For {header.Cf-Connecting-Ip}
          header_up X-Forwarded-Proto https
          header_up Host {host}
        }
      '';
      "guz.one:80".extraConfig = ''
        import capytal-securitytxt

        reverse_proxy http://localhost:${toString config.services.guzone.port} {
          header_up X-Real-Ip {header.Cf-Connecting-Ip}
          header_up X-Forwarded-For {header.Cf-Connecting-Ip}
          header_up X-Forwarded-Proto https
          header_up Host {host}
        }
      '';
      "keikos.work:80".extraConfig = ''
        import capytal-securitytxt

        reverse_proxy http://localhost:${toString config.services.keikos.web.port} {
          header_up X-Real-Ip {header.Cf-Connecting-Ip}
          header_up X-Forwarded-For {header.Cf-Connecting-Ip}
          header_up X-Forwarded-Proto https
          header_up Host {host}
        }
      '';
      "kois.work:80".extraConfig = ''
        redir https://kois.work{uri} permanent
      '';
    };
    extraConfig = ''
      (capytal-securitytxt) {
        handle_path /.well-known/security.txt {
          root "${./security.txt.asc}"
          file_server
        }
      }
    '';
  };

  sops.secrets = {
    "services/keiko/env-file" = {owner = config.services.keikos.web.user;};
  };
}
