{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.forgejo;
  users = (builtins.attrValues (builtins.mapAttrs
    (username: info: {
      name = if isNull info.name then username else info.name;
      email = info.email;
      password = info.password;
      admin = info.admin;
    })
    cfg.settings.users));
in
{
  imports = [ ];
  options.homelab.forgejo = with lib; with lib.types; {
    enable = mkEnableOption "";
    user = mkOption {
      type = str;
      default = "forgejo";
    };
    package = mkOption {
      type = package;
      default = pkgs.forgejo;
    };
    cliAlias = mkOption {
      type = bool;
      default = true;
    };
    domain = mkOption {
      type = str;
      default = "forgejo." + config.homelab.domain;
    };
    port = mkOption {
      type = port;
      default = 3020;
    };
    data = {
      root = mkOption {
        type = path;
        default = config.homelab.storage + /forgejo;
      };
    };
    handleUndeclaredUsers = mkOption {
      type = bool;
      default = false;
    };
    settings = {
      users = mkOption {
        type = attrsOf (submodule ({ config, lib, ... }: with lib; with lib.types; {
          options = {
            name = mkOption {
              type = nullOr (either str path);
              default = null;
            };
            password = mkOption {
              type = either str path;
            };
            email = mkOption {
              type = either str path;
            };
            admin = mkOption {
              type = bool;
              default = false;
            };
          };
        }));
        default = { };
      };
      name = mkOption {
        type = str;
        default = "Forgejo: Beyond coding. We forge";
      };
      prod = mkOption {
        type = bool;
        default = true;
      };
      repo.defaultUnits = mkOption {
        type = listOf (enum [
          "repo.code"
          "repo.releases"
          "repo.issues"
          "repo.pulls"
          "repo.wiki"
          "repo.projects"
          "repo.packages"
          "repo.actions"
        ]);
        default = [
          "repo.code"
          "repo.issues"
          "repo.pulls"
        ];
      };
      repo.disabledUnits = mkOption {
        type = listOf (enum [
          "repo.issues"
          "repo.ext_issues"
          "repo.pulls"
          "repo.wiki"
          "repo.ext_wiki"
          "repo.projects"
          "repo.packages"
          "repo.actions"
        ]);
        default = [ ];
      };
      cors.enable = mkOption {
        type = bool;
        default = false;
      };
      cors.domains = mkOption {
        type = listOf str;
        default = [ ];
      };
      cors.methods = mkOption {
        type = listOf str;
        default = [ ];
      };
      ui.defaultTheme = mkOption {
        type = str;
        default = "forgejo-auto";
      };
      ui.themes = mkOption {
        type = listOf str;
        default = [
          "forgejo-auto"
          "forgejo-light"
          "forgejo-dark"
          "auto"
          "gitea"
          "arc-green"
        ];
      };
      server.protocol = mkOption {
        type = enum [ "http" "https" "fcgi" "http+unix" "fcgi+unix" ];
        default = "http";
      };
      server.domain = mkOption {
        type = str;
        default = cfg.domain;
      };
      server.port = mkOption {
        type = port;
        default = cfg.port;
      };
      server.address = mkOption {
        type = either str path;
        default = if hasSuffix "+unix" cfg.settings.server.protocol then "/run/forgejo/forgejo.sock" else "0.0.0.0";
      };
      server.url = mkOption {
        type = str;
        default = "http://${cfg.settings.server.domain}:${toString cfg.settings.server.port}";
      };
      server.offline = mkOption {
        type = bool;
        default = false;
      };
      server.compression = mkOption {
        type = bool;
        default = false;
      };
      server.landingPage = mkOption {
        type = enum [ "home" "explore" "organizations" "login" str ];
        default = "home";
      };
      service.registration = mkOption {
        type = bool;
        default = false;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      package = cfg.package;
      user = cfg.user;
      group = cfg.user;
      stateDir = toString cfg.data.root;
      useWizard = false;
      database = {
        user = cfg.user;
        type = "sqlite3";
      };
      settings = with builtins; {
        DEFAULT = {
          APP_NAME = cfg.settings.name;
          RUN_MODE = if cfg.settings.prod then "prod" else "dev";
        };
        repository = {
          DISABLED_REPO_UNITS = concatStringsSep "," cfg.settings.repo.disabledUnits;
          DEFAULT_REPO_UNITS = concatStringsSep "," cfg.settings.repo.defaultUnits;
        };
        cors = {
          ENABLED = cfg.settings.cors.enable;
          ALLOW_DOMAIN = concatStringsSep "," cfg.settings.cors.domains;
          METHODS = concatStringsSep "," cfg.settings.cors.methods;
        };
        ui = {
          DEFAULT_THEME = cfg.settings.ui.defaultTheme;
          THEMES = concatStringsSep "," cfg.settings.ui.themes;
        };
        server = {
          PROTOCOL = cfg.settings.server.protocol;
          DOMAIN = cfg.settings.server.domain;
          ROOT_URL = cfg.settings.server.url;
          HTTP_ADDR = cfg.settings.server.address;
          HTTP_PORT = cfg.settings.server.port;
          OFFLINE_MODE = cfg.settings.server.offline;
          ENABLE_GZIP = cfg.settings.server.compression;
          LANDING_PAGE = cfg.settings.server.landingPage;
        };
        service = {
          DISABLE_REGISTRATION = if cfg.settings.service.registration then false else true;
        };
      };
    };
    systemd.services."homelab-forgejo-setup" = with builtins; {
      script = ''
        gum="${pkgs.gum}/bin/gum"
        forgejo="${cfg.package}/bin/gitea --work-path ${cfg.data.root}"
        user="$forgejo admin user"
        awk="${pkgs.gawk}/bin/awk"

        declaredUsers=(${toString (map (user: "${if isPath user.name then "$(cat ${toString user.name})" else user.name}") users)});

        $gum log --structured --time timeonly --level info "HANDLING UNDECLARED USERS"
        
        $user list | $awk '{print $2}' | tail -n +2 | while read username; do
          if printf '%s\0' "''${declaredUsers[@]}" | grep -Fxqz -- "$username"; then
            $gum log --structured --time timeonly --level warn "Declared user already exists, ignoring" username $username;
          else
            if [[ "$($user list | tail -n +2 | $awk '{print $2 " " $5}' | grep "$username " | $awk '{print $2}')" == "true" ]]; then
              $gum log --structured --time timeonly --level warn "Undeclared user is a ADMIN, ignoring" username $username;
            else
              ${if cfg.handleUndeclaredUsers then ''
                $gum log --structured --time timeonly --level warn "DELETING undeclared user" username $username;

                $user delete -u "$username";
              '' else ''
                $gum log --structured --time timeonly --level warn "UNDECLARED user, please declare it in the config so it's reproducible" username "$username";
              ''}
            fi
          fi
        done

        ${toString (map (user: ''
          username="${if isPath user.name then "\"$(cat ${toString user.name})\"" else user.name}";
          email="${if isPath user.email then "\"$(cat ${toString user.email})\"" else user.email}";
          password="${if isPath user.password then "\"$(cat ${toString user.password})\"" else user.password}";

          if [[ "$($user list | grep "$username" | $awk '{print $2}')" ]]; then
            $gum log --structured --time timeonly --level warn "User with username already exists" username $username;

          elif [[ "$($user list | grep "$email" | $awk '{print $3}')" ]]; then
            $gum log --structured --time timeonly --level warn "User with email already exists" email $email;

          else
            $gum log --structured --time timeonly --level info ${if user.admin then "Creating ADMIN user" else "Creating user"} username $username email $email password $password;
            $user create --username $username --email $email --password $password ${if user.admin then "--admin" else ""};

          fi
        '') users)}
      '';
      wantedBy = [ "multi-user.target" ];
      after = [ "forgejo.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.user;
      };
    };
  };
}








