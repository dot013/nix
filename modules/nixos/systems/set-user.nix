{ config, pkgs, inputs, lib, ... }:

let
  cfg = config.set-user;
in
{
  options.set-user = with lib; with lib.types; {
    users = mkOption {
      default = [ ];
      type = listOf (submodule ({ ... }: {
        username = str;
        description = str;
        normalUser = bool;
        shell = package;
        packages = types.pkgs;
        extraGroups = listOf str;
        home = anything;
        flatpak = bool;
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
                if u?description then u.description else u.username;
              isNormalUser =
                if u?normalUser then u.normalUser else true;
              shell =
                if u?shell then u.shell else pkgs.bash;
              packages =
                if u?packages then u.packages else [ ];
              extraGroups =
                if u?extraGroups then u.extraGroups else [ "networkmanager" "wheel" ];
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

