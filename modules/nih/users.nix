{ config, inputs, lib, pkgs, ... }:

let
  cfg = config.nih;
  hmModule = lib.types.submoduleWith {
    description = "Home Manager module";
    specialArgs = {
      lib = lib;
      osConfig = config;
    };
    modules = [
      ({ name, ... }: {
        config = {
          submoduleSupport.enable = true;
          submoduleSupport.externalPackageInstall = cfg.useUserPackages;

          home.username = config.users.users.${name}.name;
          home.homeDirectory = config.users.users.${name}.home;

          # Make activation script use same version of Nix as system as a whole.
          # This avoids problems with Nix not being in PATH.
          nix.package = config.nix.package;
        };
      })
    ] ++ config.home-manager.sharedModules;
  };
in
{
  imports = [ ];
  options.nih = with lib; with lib.types; {
    users = mkOption {
      type = attrsOf
        (submodule ({ ... }: {
          options = {
            description = mkOption {
              type = nullOr str;
              default = null;
            };
            extraGroups = mkOption {
              type = listOf str;
              default = [ "networkmanager" "wheel" ];
            };
            home = mkOption {
              type = attrsOf anything;
              default = { };
            };
            normalUser = mkOption {
              type = bool;
              default = true;
            };
            packages = mkOption {
              type = listOf package;
              default = [ ];
            };
            password = mkOption {
              type = nullOr (passwdEntry str);
              default = null;
            };
            profiles = mkOption {
              type = attrsOf anything;
              default = { };
            };
            programs = mkOption {
              type = attrsOf anything;
              default = { };
            };
            services = mkOption {
              type = attrsOf anything;
              default = { };
            };
            shell = mkOption {
              type = package;
              default = pkgs.bash;
            };
            username = mkOption {
              type = passwdEntry str;
              apply = x: assert (builtins.stringLength
                x < 32 || abort "Username '${x}' is longer than 31 characters"); x;
            };
          };
        }));
    };
  };
  config = with lib; {
    users.users =
      (builtins.mapAttrs
        (name: value: {
          name = value.username;
          hashedPassword = value.password;
          description = if value.description != null then value.description else value.username;
          isNormalUser = value.normalUser;
          shell = value.shell;
          extraGroups = value.extraGroups ++ [ "wheel" ];
        })
        cfg.users);

    users.mutableUsers = true;

    home-manager.extraSpecialArgs = { inherit inputs; };
    home-manager.users =
      (builtins.mapAttrs
        (name: value: mkMerge [
          {
            imports = [
              inputs.nix-index-database.hmModules.nix-index
              inputs.flatpaks.homeManagerModules.nix-flatpak
              ./programs
            ];
            options = with lib; with lib.types; {
              _nih = mkOption {
                type = attrsOf anything;
                default = { };
              };
            };
            config = {

              _nih = {
                type = config.nih.type;
              };
              programs = mkMerge [
                { home-manager.enable = true; }
                value.programs
              ];

              services = mkMerge [
                { flatpak.enable = mkDefault true; }
                value.services
              ];

              home = mkMerge [
                {
                  username = value.username;
                  homeDirectory = mkDefault
                    "/home/${value.username}";
                  stateVersion = mkDefault
                    "23.11"; # Do not change
                }
                value.home
              ];
            };
          }
        ])
        cfg.users);
  };
}
