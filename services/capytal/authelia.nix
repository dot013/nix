{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.services.authelia.instances."capytal";
in {
  services.authelia.instances."capytal" = {
    enable = true;
    settings = {
      access_control = {
        default_policy = "deny";
        rules = mkAfter [
          {
            domain = "*.capytal.cc";
            policy = "two_factor";
          }
        ];
      };
      authentication_backend.ldap = {
        address = "ldap://localhost:${toString config.services.lldap.settings.ldap_port}";
        implementation = "lldap";
        tls.skip_verify = true;
        base_dn = config.services.lldap.settings.ldap_base_dn;
        users_filter = "(&({username_attribute}={input})(objectClass=person))";
        groups_filter = "(member={dn})";
        user = "uid=authelia,ou=people,dc=capytal,dc=cc";
      };
      duo_api.disable = true;
      notifier.filesystem.filename = "/var/lib/authelia-capytal/notification.txt";
      server = {
        endpoints = {
          authz.forward-auth.implementation = "ForwardAuth";
        };
        timeouts = {
          read = "1m";
          write = "1m";
          idle = "2m";
        };
      };
      session = {
        redis.host = "/var/run/redis-authelia-capytal/redis.sock";
        name = "authelia_session";
        same_site = "lax";
        inactivity = "5m";
        expiration = "1h";
        remember_me = "1M";
        cookies = [
          {
            domain = "capytal.cc";
            authelia_url = "https://auth.capytal.cc";
            name = "capytal_authelia_session";
          }
        ];
      };
      storage.postgres = {
        address = "tcp://localhost:${toString config.services.postgresql.settings.port}";
        database = "authelia-capytal";
        username = "authelia-capytal";
      };
      theme = "dark";
      totp = {
        disable = false;
        issuer = "auth.capytal.cc";
      };
    };
    environmentVariables = {
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.sops.secrets."services/authelia/ldap-passowrd".path;
    };
    settingsFiles = [
      config.sops.secrets."services/authelia/settings-file".path
    ];
    secrets = {
      jwtSecretFile = config.sops.secrets."services/authelia/jwt-secret".path;
      oidcHmacSecretFile = config.sops.secrets."services/authelia/oidc-hmac-secret".path;
      oidcIssuerPrivateKeyFile = config.sops.secrets."services/authelia/oidc-issuer-private-key".path;
      sessionSecretFile = config.sops.secrets."services/authelia/session-secret".path;
      storageEncryptionKeyFile = config.sops.secrets."services/authelia/storage-encryption-key".path;
    };
  };

  users.users."authelia-capytal".extraGroups = ["redis-authelia-capytal"];
  systemd.services."authelia-capytal" = {
    after = ["lldap.service" "postgresql.service" "redis-authelia-capytal.service"];
    requires = ["lldap.service" "postgresql.service" "redis-authelia-capytal.service"];
  };

  services.caddy = {
    virtualHosts."auth.capytal.cc:80".extraConfig = ''
      reverse_proxy :9091 {
        header_up X-Real-Ip {header.Cf-Connecting-Ip}
        header_up X-Forwarded-For {header.Cf-Connecting-Ip}
        header_up X-Forwarded-Proto https
        header_up X-Http-Version {http.request.proto}
        header_up Host {host}
      }
    '';
    virtualHosts."lldap.local".extraConfig = ''
      reverse_proxy :${toString config.services.lldap.settings.http_port}
    '';
    # A snippet that can be imported to enable Authelia in front of a service
    # https://www.authelia.com/integration/proxies/caddy/#subdomain
    extraConfig = ''
      (auth) {
        forward_auth :9091 {
          header_up X-Real-Ip {header.Cf-Connecting-Ip}
          header_up X-Forwarded-For {header.Cf-Connecting-Ip}
          header_up X-Forwarded-Proto https
          header_up X-Http-Version {http.request.proto}
          header_up Host {host}

          uri /api/authz/forward-auth
          copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
        }
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];

  services.lldap.enable = true;
  services.lldap.settings = {
    ldap_base_dn = "dc=capytal,dc=cc";
    ldap_user_email = "contact@capytal.cc";
    ldap_user_pass_file = config.sops.secrets."services/lldap/admin-password".path;
    force_ldap_user_pass_reset = "always";
    database_url = "postgresql://lldap@localhost/lldap?host=/run/postgresql";
  };
  services.lldap.environmentFile = config.sops.secrets."services/lldap/environment".path;

  systemd.services.lldap = {
    after = ["postgresql.service"];
    requires = ["postgresql.service"];
    serviceConfig = {
      User = "lldap";
      Group = "lldap";
      DynamicUser = mkForce false;
      StateDirectory = mkForce null;
    };
  };
  users.users.lldap = {
    isSystemUser = true;
    group = "lldap";
  };
  users.groups.lldap = {};

  sops.secrets = {
    "services/authelia/jwt-secret" = {owner = cfg.user;};
    "services/authelia/ldap-passowrd" = {owner = cfg.user;};
    "services/authelia/oidc-hmac-secret" = {owner = cfg.user;};
    "services/authelia/oidc-issuer-private-key" = {owner = cfg.user;};
    "services/authelia/session-secret" = {owner = cfg.user;};
    "services/authelia/storage-encryption-key" = {owner = cfg.user;};
    "services/authelia/settings-file" = {owner = cfg.user;};

    "services/lldap/admin-password" = {owner = "lldap";};
    "services/lldap/environment" = {owner = "lldap";};
  };
}
