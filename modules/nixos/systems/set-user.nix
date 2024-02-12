{ config, pkgs, inputs, lib, ... }:

let
  cfg = config.set-user;
in
{
  options.set-user = with lib; with lib.types; {
    users = mkOption {
      default = [ ];
      type = listOf (submodule ({ ... }: {
        options = {
          username = mkOption {
            type = str;
          };
          description = mkOption {
            type = nullOr str;
            default = null;
          };
          normalUser = mkOption {
            type = bool;
            default = true;
          };
          shell = mkOption {
            type = package;
            default = pkgs.bash;
          };
          packages = mkOption {
            type = listOf package;
            default = [ ];
          };
          extraGroups = mkOption {
            type = listOf str;
            default = [ "networkmanager" "wheel" ];
          };
          home = mkOption {
            type = anything;
          };
          flatpak = mkOption {
            type = nullOr bool;
            default = true;
          };
        };
      }));
    };
  };
  config =
    let
      home-default = user: {
        imports = [
          (
            if user?flatpak && !user.flatpak
            then null
            else inputs.flatpaks.homeManagerModules.nix-flatpak
          )
          inputs.nix-index-database.hmModules.nix-index
        ];
        programs.home-manager.enable = true;
        home.username = user.username;
        home.homeDirectory = "/home/${user.username}";
        home.stateVersion = "23.11"; # Do not change
      };
    in
    {
      users.users = (builtins.listToAttrs
        (map
          (u: {
            name = u.username;
            value = {
              description =
                if u.description != null then u.description else u.username;
              isNormalUser = u.normalUser;
              shell = u.shell;
              packages = u.packages;
              extraGroups = u.extraGroups ++ [ "wheel" ];
            };
          })
          cfg.users
        )
      );
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users = (builtins.listToAttrs
        (map
          (u: {
            name = u.username;
            value =
              if u?home then lib.mkMerge [ (home-default u) u.home ]
              else (home-default u);
          })
          cfg.users
        )
      );
    };
}

