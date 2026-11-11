rec {
  service = {
    config,
    lib,
    ...
  }:
    with lib; let
      cfg = config.services.adguardhome;
      removeProto = l: removePrefix "https://" (removePrefix "http://" l);
    in {
      imports = [
        tls-trust
      ];
      options.services.caddy.virtualHosts = mkOption {
        apply = v:
          (mapAttrs' (n: v:
            if hasSuffix ".local" v.hostName
            then
              nameValuePair "${removeProto v.hostName}" (v
                // {
                  hostName = removeProto v.hostName;
                  serverAliases = [
                    "https://${removeProto v.hostName}"
                    "${removeProto v.hostName}:443"
                  ];
                  extraConfig = ''
                    ${v.extraConfig}
                    tls ${config.sops.secrets."services/adguard/cert".path} ${config.sops.secrets."services/adguard/key".path}
                  '';
                })
            else nameValuePair n v)
          v)
          // (mapAttrs' (n: v:
            nameValuePair "${removeProto v.hostName}:80" (v
              // {
                hostName = "${removeProto v.hostName}:80";
                serverAliases = ["http://${removeProto v.hostName}"];
              }))
          (filterAttrs (_: v: (hasSuffix ".local" v.hostName)) v));
      };
      config = {
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
              upstram_dns = [
                "9.9.9.9"
              ];
              fallback_dns = [
                "1.1.1.1"
                "8.8.8.8"
              ];
            };
            filtering = {
              rewrites = mkIf config.services.caddy.enable (pipe config.services.caddy.virtualHosts [
                (filterAttrs (n: _: hasSuffix ".local" n))
                (mapAttrsToList (n: _: {
                  domain = n;
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

        services.caddy.virtualHosts."adguard.local".extraConfig = ''
          reverse_proxy http://localhost:${toString cfg.port}
        '';

        sops.secrets = {
          "services/adguard/cert" = {owner = config.services.caddy.user;};
          "services/adguard/key" = {owner = config.services.caddy.user;};
        };

        environment.etc."caddy-local-domains".text = join " " (mapAttrsToList (_: v: v.hostName)
          (filterAttrs (_: v: (hasSuffix ".local" v.hostName))
            config.services.caddy.virtualHosts));

        # Ports needed to access the DNS resolver
        networking.firewall.allowedTCPPorts = [53 443 80];
        networking.firewall.allowedUDPPorts = [53 443 80 51820];
      };
    };
  tls-trust = {pkgs, ...}: {
    security.pki.certificateFiles = [
      (pkgs.writeText "local.crt" ''
        -----BEGIN CERTIFICATE-----
        MIIEgzCCAuugAwIBAgIQavxInWePQZcO3q7IRwYzhjANBgkqhkiG9w0BAQsFADBb
        MR4wHAYDVQQKExVta2NlcnQgZGV2ZWxvcG1lbnQgQ0ExGDAWBgNVBAsMD2d1ekBk
        cmVhZG5vdWdodDEfMB0GA1UEAwwWbWtjZXJ0IGd1ekBkcmVhZG5vdWdodDAeFw0y
        NjExMTEyMzIyMDlaFw0yOTAyMTEyMzIyMDlaMEMxJzAlBgNVBAoTHm1rY2VydCBk
        ZXZlbG9wbWVudCBjZXJ0aWZpY2F0ZTEYMBYGA1UECwwPZ3V6QGRyZWFkbm91Z2h0
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAt/g242rRUDaJ6ISzAHlM
        0diV6XD3EN97yeKTJTiwAKIOIeXgez9FrZUqY1Cq6U1Q/bTAsB19+MNhIL6vLUXD
        QrB7BUBlifA7sfqVP2heb2PSKJ5ZGY8jUSQzkRILaJe5oDnoTAvKQFY/9rI2NER5
        yu3sMJag4z0RVHumv/UP2yYSdnpkKMAV+Mg8eTMbuDz9SIZP6QpuBSELzaWNQqF9
        e+4ndmCh4fRGHxvdb+x47321cc8i4P1fTiWEu9BGBSdgZXvvA7yEFictcZ0o/3Hj
        Ew/wc1ncXyKat8UHvc/nJOPZg2lXW1b6fBYwNxmnpkRKlbkajq4MrYBoYe7/UJWR
        ZwIDAQABo4HaMIHXMA4GA1UdDwEB/wQEAwIFoDATBgNVHSUEDDAKBggrBgEFBQcD
        ATAfBgNVHSMEGDAWgBR95ZO9HiaIPMXRutFK9yrBUnsGWzCBjgYDVR0RBIGGMIGD
        ghIqLndlYi5nYXJhZ2UubG9jYWyCDWFkZ3VhcmQubG9jYWyCC2dpdGVhLmxvY2Fs
        gg9uZXh0Y2xvdWQubG9jYWyCC2xsZGFwLmxvY2FsghBycGMuZ2FyYWdlLmxvY2Fs
        gg9zMy5nYXJhZ2UubG9jYWyCEHdlYi5nYXJhZ2UubG9jYWwwDQYJKoZIhvcNAQEL
        BQADggGBACdCSPujxynlYAl8aQmnLPUSnDww8udv9pASUq3TXrfe4wOV0jK/OaLk
        b07N7CAOJtURazWJkS29FKa7D8cOAxKVR+O12QKhJwn5wB5+idPwkfoFzZFJU32u
        a51af636UOIKgXX9SW7s8UNvzOrniaVQUPwbjxGPkgKqDD3hmkMUHaXlMO44Wv/k
        Fv45Mtz3WJY9A9SkxPeegb7XNs4c3do1hAodn8RFwYia5pcJnK4AylQQPCIye1Kg
        XhgMzDSf90RkD3RdPqIrsSzH5uOAffrptqRjdPz84HefC9iIVQHzdsb0aBTXHkHZ
        k1+CpicOVPvo5h9xRFBcKMo7T0BMq3Ffkb9HpPwTscbUhLgudnyEvcl1zHAUbwHx
        aI85AeVpcFTfbNBxsGyN/99gtix5y7Bm8cXLvxd8iw/+XSQk70AFjXjhKpU4oJyP
        I41gNsURVzKYpewUdqc3JAb46GhZRKONdePLu35oSKPKq6eucIg63F2M6CyMku1b
        QSjV0V+9bw==
        -----END CERTIFICATE-----
      '')
      (pkgs.writeText "mkcert.crt" ''
        -----BEGIN CERTIFICATE-----
        MIIEhTCCAu2gAwIBAgIQdj5CIGhqpJY3XoQnNtw5RDANBgkqhkiG9w0BAQsFADBb
        MR4wHAYDVQQKExVta2NlcnQgZGV2ZWxvcG1lbnQgQ0ExGDAWBgNVBAsMD2d1ekBk
        cmVhZG5vdWdodDEfMB0GA1UEAwwWbWtjZXJ0IGd1ekBkcmVhZG5vdWdodDAeFw0y
        NjExMTEyMTUxMjRaFw0zNjExMTEyMTUxMjRaMFsxHjAcBgNVBAoTFW1rY2VydCBk
        ZXZlbG9wbWVudCBDQTEYMBYGA1UECwwPZ3V6QGRyZWFkbm91Z2h0MR8wHQYDVQQD
        DBZta2NlcnQgZ3V6QGRyZWFkbm91Z2h0MIIBojANBgkqhkiG9w0BAQEFAAOCAY8A
        MIIBigKCAYEA6yIl+NZ1lr/5nvHTEG4vY3/3YZKNPP5x4uMGG595PWzWLUsRUwNG
        PXMreSqBLHgXal45ZTp7K1MGwK2MQA63HC53VtjwBWT+MKD1PdGnXttCrKyyoxig
        4Y2OP9LWELRukApzylmjgVFzHDob8SX8eiHamjMmMn/fZZBiRE/uFofDVl4ySAIP
        ZX4EoHu1KQKT8EQRx3LGFu49mpnNLWLbMNVrgHlaW3Y/osr+700W+4SilgrdIDXY
        5dg0bNJXRj9rrWgwHcyYV0dQjpgx3XN0UQU6Vs3EOV4bME8uWsOlsQ1lz9uQulTW
        bolGvc82p6p5wKNpzmkDTQ9oM0uliht4ZSqovokxXPibme37yd2YswSRQxooSFQ1
        s2TaoUrcoQB6cHT2QXOEFq6syE6hJ5OQz93/GRYe46fHuwoiE28d/wyR4WKrTKha
        9fj5fe/ElgZtg4SBdk81+3CDUK91VrIhLeLWzyoTK+ToAv3G7lb/uaOWnbr0ZBdJ
        yHIPNU8BqslVAgMBAAGjRTBDMA4GA1UdDwEB/wQEAwICBDASBgNVHRMBAf8ECDAG
        AQH/AgEAMB0GA1UdDgQWBBR95ZO9HiaIPMXRutFK9yrBUnsGWzANBgkqhkiG9w0B
        AQsFAAOCAYEAmZ2M6yeV/WCA/7NrOrubZs1RhEoCqKnHJlIlX9nz/ndS129wuXnQ
        shW4Q/VY/H5s4T/ECCoyPVchQkFQE7oCnztvz8fMTyJHM9tr2qRM+h/8/2YIy7aJ
        991ongnkW96zB6tVnTMTv2yo4aphihSya1ZAAnqzBxQvsRWSpmBhbY2LJI1PurUC
        apJtTJS8XaiBOwTh0ZaC2wvWqnVX9rvZ29PCi3lFm011tn2eGD/JlvX90rIEz6Lf
        f83CBw5WlvKko/bywMR3moGPr1maF3ltJme/z90O3GhqF21EgrgRc0hPS2Dlx22h
        EiNimcxYmxD4+gUJxBoNd5Zz8cx4hLuPqUjn2mdCviH7V392esjI5ryrgpUb9LjO
        eN2iiBvIdy8JB32m1SKdU6Q5+ic68Ei6d11JjRB2hCfYxsRc+b6T6NhOywoJLXrd
        3nmtyyNj2RDHl4i3awE1zUP3vEk68uQYfi4HntZ6epPG+PhoMk8IkqxmGWtgCXRe
        pfLSK4mJTASU
        -----END CERTIFICATE-----
      '')
    ];
  };
}
