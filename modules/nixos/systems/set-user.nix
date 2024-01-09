{ config, pkgs, inputs, lib, ... }:

let
  cfg = config.set-user;
in
{
  options.set-user = {
    users = lib.mkOption {
      default = [ ];
      # TODO: Fix types
      /* type = lib.types.listOf {
        username = lib.types.str;
        description = lib.types.str;
        normalUser = lib.types.bool;
        shell = lib.types.package;
        packages = lib.types.pkgs;
        extraGroups = lib.types.listOf lib.types.str;
        home = lib.types.anything;
        flatpak = lib.types.bool;
      }; */
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

