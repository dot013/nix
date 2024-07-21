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
      enable = mkOption {
        type = bool;
        default = cfg.enable;
      };
      token = mkOption {
        type = str;
      };
      url = mkOption {
        type = str;
        default = "http://localhost:${toString cfg.settings.server.HTTP_PORT}";
      };
      labels = mkOption {
        type = listOf str;
        default = [
          /*
          Remember to install git on these images so actions/checkout can work,
          without it, the actions tries to use the /api/v3/repos/{user}/{repo}/tarball/{ref}
          api endpoint, which Gitea/Forgejo doesn't has.
          */
          "ubuntu-latest:docker://gitea/runner-images:ubuntu-latest-slim"
          "ubuntu-latest-full:docker://gitea/runner-images:ubuntu-latest"
        ];
      };
    };
  };
  config = with lib;
    mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = mkIf cfg.settings.actions.ENABLED [
        cfg.settings.server.HTTP_PORT
      ];
      networking.firewall.allowedUDPPorts = mkIf cfg.settings.actions.ENABLED [
        cfg.settings.server.HTTP_PORT
      ];

      users.users."${cfg.user}" = {
        home = cfg.stateDir;
        useDefaultShell = true;
        group = cfg.group;
        isSystemUser = true;
        extraGroups = ["wheel" "networkmanager"];
      };
      users.groups."${cfg.group}" = {};

      services.forgejo = {
        user = mkDefault "git";
        group = mkDefault cfg.user;
        settings = {
          DEFAULT = {
            APP_NAME = mkDefault "Forgejo: Beyond coding. We forge.";
          };
          actions = {
            ENABLED = mkDefault cfg.actions.enable;
            DEFAULT_ACTIONS_URL = mkDefault "http://localhost:${toString cfg.settings.server.HTTP_PORT}";
          };
          repository = {
            DEFAULT_REPO_UNITS = mkDefault (initList [
              "repo.code"
            ]);
            DISABLED_REPO_UNITS = mkIf (!cfg.actions.enable) (mkDefault (initList [
              "repo.actions"
            ]));
          };
          service = {
            # DISABLE_REGISTRARION = mkDefault true;
          };
        };
      };

      virtualisation.docker.enable = mkIf cfg.actions.enable (mkDefault true);
      services.gitea-actions-runner = mkIf cfg.actions.enable {
        package =
          if config.services.gitea.enable
          then pkgs.gitea-actions-runner
          else pkgs.forgejo-actions-runner;
        instances."forgejo${toString cfg.settings.server.HTTP_PORT}" = {
          enable = mkDefault true;
          token = mkDefault cfg.actions.token;
          name = mkDefault "${cfg.settings.DEFAULT.APP_NAME} - Actions";
          url = cfg.actions.url;
          labels = mkDefault cfg.actions.labels;
          settings = {
            runner = {
              insecure = true;
            };
          };
        };
      };

      systemd.services."forgejo-users-setup" = with builtins; {
        script = ''
          function gum() { ${pkgs.gum}/bin/gum "$@"; }
          function forgejo() {
            # local config_file="${toString cfg.stateDir}/custom/conf/app.ini";
            # touch $config_file
            ${cfg.package}/bin/gitea \
              --work-path ${cfg.stateDir} \
              "$@"
          }
          function fjuser() { forgejo admin user "$@"; }
          function awk() { ${pkgs.gawk}/bin/awk "$@"; }

          handle_undeclared_users="${
            if cfg.handleUndeclaredUsers
            then "true"
            else "false"
          }";

          declared_users=(${toString (map (user: "${
              if isPath user.name
              then "$(cat ${toString user.name})"
              else user.name
            }")
            users)});

          ${readFile ./user-handler.sh}

          ${toString (map (user: ''
              set-user "${
                if isPath user.name
                then "$(cat ${toString user.name})"
                else user.name
              }" "${
                if isPath user.email
                then "$(cat ${toString user.email})"
                else user.email
              }" "${
                if isPath user.password
                then "$(cat ${toString user.password})"
                else user.password
              }" \
                       "${
                if user.admin
                then "true"
                else "false"
              }"
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
