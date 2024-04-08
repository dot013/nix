{
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  cfg = config.services.forgejo;
  yamlFormat = pkgs.formats.yaml {};
  users = builtins.attrValues (builtins.mapAttrs
    (username: info: {
      name =
        if isNull info.name
        then username
        else info.name;
      email = info.email;
      password = info.password;
      admin = info.admin;
    })
    cfg.users);
  initList = l: lib.strings.concatStringsSep "," l;
in {
  imports = [];
  options.services.forgejo = with lib;
  with lib.types; {
    handleUndeclaredUsers = mkOption {
      type = bool;
      default = false;
    };
    users = mkOption {
      type = attrsOf (submodule ({
        config,
        lib,
        ...
      }:
        with lib;
        with lib.types; {
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
      default = {};
    };
    actions = {
      enable = mkEnableOption "";
      hostPackages = mkOption {
        type = listOf package;
        default = with pkgs; [
          bash
          coreutils
          curl
          gawk
          gitMinimal
          gnused
          nodejs
          wget
        ];
      };
      labels = mkOption {
        type = listOf str;
        default = [
          "host:host"
          "shell:host://-self-hosted"
          "debian-latest:docker://node:18-bullseye"
          "ubuntu-latest:docker://node:18-bullseye"
          "debian-slim:docker://node:18-bullseye-slim"
          "ubuntu-slim:docker://node:18-bullseye-slim"
          "alpine-latest:docker://alpine:latest"
        ];
      };
      name = mkOption {
        type = str;
        default = "Forgejo ${toString cfg.settings.server.HTTP_PORT} - Actions Runner";
      };
      package = mkOption {
        type = package;
        default = pkgs.forgejo-actions-runner;
      };
      settings = mkOption {
        type = yamlFormat.type;
        default = {};
      };
      token = mkOption {
        type = nullOr str;
        default = null;
      };
      tokenFile = mkOption {
        type = nullOr (either path str);
        default = null;
      };
      url = mkOption {
        type = str;
        default = cfg.settings.server.ROOT_URL;
      };
    };
  };
  config = with lib;
    mkIf cfg.enable {
      # this opens the port for the internal actions be able to clone and interact with the instance
      networking.firewall.allowedTCPPorts =
        mkIf cfg.actions.enable [cfg.settings.server.HTTP_PORT];

      services.forgejo.settings = {
        actions = {
          ENABLED = mkDefault cfg.actions.enable;
          DEFAULT_ACTIONS_URL = mkDefault cfg.settings.server.ROOT_URL;
        };
        repository = {
          DEFAULT_REPO_UNITS = mkDefault (initList [
            "repo.code"
            "repo.issues"
            "repo.pulls"
          ]);
          DISABLED_REPO_UNITS = mkIf (!cfg.actions.enable) (mkDefault "repo.actions");
        };
        security = {
          ONLY_ALLOW_PUSH_IF_GITEA_ENVIRONMENT_SET = mkDefault true;
        };
        server = {
          HTTP_PORT = mkDefault 3617;
          DOMAIN =
            mkIf config.services.tailscale.enable
            (mkDefault "${config.services.tailscale.deviceUrl}");
        };
        service = {
          DISABLE_REGISTRATION = mkDefault true;
        };
      };

      virtualisation.docker.enable = mkIf cfg.settings.actions.ENABLED (mkDefault true);
      services.gitea-actions-runner.instances."generatedForgejo${toString cfg.settings.server.HTTP_PORT}" = mkIf cfg.actions.enable {
        enable = mkDefault true;
        hostPackages = mkDefault cfg.actions.hostPackages;
        labels = mkDefault cfg.actions.labels;
        name = mkDefault cfg.actions.name;
        settings = mkDefault cfg.actions.settings;
        url = mkDefault cfg.actions.url;
        token = cfg.actions.token;
      };
      systemd.services = {
        "${utils.escapeSystemdPath "generatedForgejo${toString cfg.settings.server.HTTP_PORT}"}" = {
          serviceConfig.User = mkIf cfg.actions.enable (mkDefault cfg.user);
        };
      };

      systemd.services."homelab-forgejo-setup" = with builtins; {
        script = ''

          configFile="${toString cfg.stateDir}/custom/conf/app.ini";
          touch $configFile

          gum="${pkgs.gum}/bin/gum"
          forgejo="${cfg.package}/bin/gitea --config $configFile"
          user="$forgejo admin user"
          awk="${pkgs.gawk}/bin/awk"

          declaredUsers=(${toString (map (user: "${
              if isPath user.name
              then "$(cat ${toString user.name})"
              else user.name
            }")
            users)});

          $gum log --structured --time timeonly --level info "HANDLING UNDECLARED USERS"

          $user list | $awk '{print $2}' | tail -n +2 | while read username; do
            if printf '%s\0' "''${declaredUsers[@]}" | grep -Fxqz -- "$username"; then
              $gum log --structured --time timeonly --level warn "Declared user already exists, ignoring" username $username;
            else
              if [[ "$($user list | tail -n +2 | $awk '{print $2 " " $5}' | grep "$username " | $awk '{print $2}')" == "true" ]]; then
                $gum log --structured --time timeonly --level warn "Undeclared user is a ADMIN, ignoring" username $username;
              else
                ${
            if cfg.handleUndeclaredUsers
            then ''
              $gum log --structured --time timeonly --level warn "DELETING undeclared user" username $username;

              $user delete -u "$username";
            ''
            else ''
              $gum log --structured --time timeonly --level warn "UNDECLARED user, please declare it in the config so it's reproducible" username "$username";
            ''
          }
              fi
            fi
          done

          ${toString (map (user: ''
              username="${
                if isPath user.name
                then "\"$(cat ${toString user.name})\""
                else user.name
              }";
              email="${
                if isPath user.email
                then "\"$(cat ${toString user.email})\""
                else user.email
              }";
              password="${
                if isPath user.password
                then "\"$(cat ${toString user.password})\""
                else user.password
              }";

              if [[ "$($user list | grep "$username" | $awk '{print $2}')" ]]; then
                $gum log --structured --time timeonly --level warn "User with username already exists" username $username;

              elif [[ "$($user list | grep "$email" | $awk '{print $3}')" ]]; then
                $gum log --structured --time timeonly --level warn "User with email already exists" email $email;

              else
                $gum log --structured --time timeonly --level info ${
                if user.admin
                then "Creating ADMIN user"
                else "Creating user"
              } username $username email $email password $password;
                $user create --username $username --email $email --password $password ${
                if user.admin
                then "--admin"
                else ""
              };

              fi
            '')
            users)}
        '';
        wantedBy = ["multi-user.target"];
        after = ["forgejo.service"];
        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          Group = cfg.group;
        };
      };
    };
}
