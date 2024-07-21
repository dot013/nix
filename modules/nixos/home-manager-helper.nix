{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.types; let
  cfg = config.home-manager-helper;
  subordinateUidRange = {
    options = {
      startUid = mkOption {
        type = int;
      };
      count = mkOption {
        type = int;
        default = 1;
      };
    };
  };

  subordinateGidRange = {
    options = {
      startGid = mkOption {
        type = int;
      };
      count = mkOption {
        type = int;
        default = 1;
      };
    };
  };
in {
  imports = [
    inputs.home-manager.nixosModules.default
  ];
  options.home-manager-helper = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    users = mkOption {
      type =
        attrsOf
        (submodule
          ({
            config,
            name,
            ...
          }: {
            options = {
              autoSubUidGidRange = mkOption {
                type = bool;
                default = false;
              };
              createHome = mkOption {
                type = bool;
                default = cfg.users.${name}.homeManager;
              };
              cryptHomeLuks = mkOption {
                type = nullOr str;
                default = null;
              };
              description = mkOption {
                type = passwdEntry str;
                default = "";
              };
              extraGroups = mkOption {
                type = listOf str;
                default = [];
              };
              group = mkOption {
                type = str;
                default = name;
              };
              hashedPassword = mkOption {
                type = nullOr (passwdEntry str);
                default = null;
              };
              hashedPasswordFile = mkOption {
                type = nullOr str;
                default = null;
              };
              home = mkOption {
                type = anything;
                default = {};
              };
              homeDirectory = mkOption {
                type = passwdEntry path;
                default =
                  if cfg.users.${name}.homeManager
                  then "/home/${name}"
                  else "/var/empty";
              };
              homeManager = mkOption {
                type = bool;
                default =
                  if cfg.users.${name}.isNormalUser
                  then true
                  else false;
              };
              homeMode = mkOption {
                type = strMatching "[0-7]{1,5}";
                default = "700";
              };
              ignoreShellProgramCheck = mkOption {
                type = bool;
                default = false;
              };
              initialHashedPassword = mkOption {
                type = nullOr (passwdEntry str);
                default = null;
              };
              initialPassword = mkOption {
                type = nullOr (passwdEntry str);
                default = null;
              };
              isNormalUser = mkOption {
                type = bool;
                default = false;
              };
              isSystemUser = mkOption {
                type = bool;
                default = false;
              };
              linger = mkOption {
                type = bool;
                default = false;
              };
              name = mkOption {
                type = passwdEntry str;
              };
              packages = mkOption {
                type = listOf package;
                default = [];
              };
              pamMount = mkOption {
                type = attrsOf str;
                default = {};
              };
              shell = mkOption {
                type = nullOr (either shellPackage (passwdEntry path));
                default = pkgs.shadow;
              };
              subGidRanges = mkOption {
                type = listOf (submodule subordinateGidRange);
                default = [];
              };
              subUidRanges = mkOption {
                type = listOf (submodule subordinateUidRange);
                default = [];
              };
              uid = mkOption {
                type = nullOr int;
                default = null;
              };
              useDefaultShell = mkOption {
                type = bool;
                default = false;
              };
            };
          }));
      default = {};
    };
  };
  config = with lib;
  with builtins;
    mkIf cfg.enable {
      users.users =
        mapAttrs
        (name: value: {
          inherit
            (value)
            autoSubUidGidRange
            createHome
            cryptHomeLuks
            description
            extraGroups
            group
            hashedPassword
            hashedPasswordFile
            homeMode
            ignoreShellProgramCheck
            initialHashedPassword
            initialPassword
            isNormalUser
            isSystemUser
            linger
            name
            pamMount
            shell
            subGidRanges
            subUidRanges
            uid
            useDefaultShell
            ;

          home = value.homeDirectory;

          packages =
            if value.homeManager
            then []
            else value.packages;
        })
        cfg.users;

      users.mutableUsers = true;
      users.groups =
        mapAttrs'
        (name: value: {
          name = name;
          value =
            mkDefault
            {
              name = name;
              members = ["${name}"];
            };
        })
        cfg.users;

      home-manager.backupFileExtension = "backup~";
      home-manager.extraSpecialArgs = {inherit inputs;};
      home-manager.users =
        mapAttrs
        (name: value: (mkMerge [
          {
            imports = [
              inputs.nix-index-database.hmModules.nix-index
              inputs.flatpaks.homeManagerModules.nix-flatpak
            ];

            home.username = value.name;
            home.homeDirectory = value.homeDirectory;
            home.packages =
              value.packages
              ++ (
                if value ? home ? packages
                then value.home.packages
                else []
              );

            programs.home-manager.enable = true;

            home.stateVersion = "23.11"; # DO NOT CHANGE
          }
          value.home
        ]))
        (filterAttrs (n: v: v.homeManager) cfg.users);
    };
}
