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
        import capytal-securityheaders
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
        import capytal-securityheaders
        import capytal-securitytxt

        reverse_proxy http://localhost:${toString config.services.guzone.port} {
          header_up X-Real-Ip {header.Cf-Connecting-Ip}
          header_up X-Forwarded-For {header.Cf-Connecting-Ip}
          header_up X-Forwarded-Proto https
          header_up Host {host}
        }
      '';
      "keikos.work:80".extraConfig = ''
        import capytal-securityheaders
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
      (capytal-securityheaders) {
        header {
          X-Frame-Options "SAMEORIGIN"
          X-Content-Type-Options "nosniff"
          X-XSS-Protection "1; mode=block"
          Referrer-Policy "strict-origin-when-cross-origin"
          Cross-Origin-Opener-Policy "same-origin"
          Cross-Origin-Resource-Policy "cross-origin"
          Cross-Origin-Embedder-Policy "credentialless"
          Content-Security-Policy "${
        join "; " [
          # TODO: needs some changes
          "default-src 'self'"
          "worker-src 'self' blob: data:"
          "script-src 'self' 'unsafe-inline'"
          "style-src 'self' 'unsafe-inline'"
          "img-src https:"
          "font-src 'self' data:"
          "upgrade-insecure-requests"
          "report-to csp-endpoint"
        ]
      }"
          Permissions-Policy "${
        join ", " ([
            "cross-origin-isolated=self"
            "encrypted-media=self"
          ]
          ++ (map (d: "${d}=()") [
            "accelerometer"
            "ambient-light-sensor"
            "attribution-reporting"
            "bluetooth"
            "browsing-topics"
            "camera"
            "captured-surface-control"
            "ch-ua-high-entropy-values"
            "compute-pressure"
            "cross-origin-isolated"
            "deferred-fetch"
            "display-captured"
            "fullscreen"
            "gamepad"
            "geolocation"
            "gyroscope"
            "hid"
            "identity-credentials-get"
            "idle-detection"
            "language-detector"
            "language-model"
            "local-fonts"
            "local-network"
            "local-network-access"
            "magnetometer"
            "microphone"
            "midi"
            "on-device-speech-recognition"
            "otp-credentials"
            "payment"
            "picture-in-picture"
            "private-state-token-issuance"
            "private-state-token-redemption"
            "publickey-credentials-create"
            "publickey-credentials-get"
            "screen-wake-lock"
            "serial"
            "speaker-selection"
            "storage-access"
            "translator"
            "summarizer"
            "usb"
            "web-share"
            "window-management"
            "xr-spatial-tracking"
          ]))
      }"
          Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        }
      }
    '';
  };

  sops.secrets = {
    "services/keiko/env-file" = {owner = config.services.keikos.web.user;};
  };
}
