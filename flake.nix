{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declaratively install flatpaks
    flatpaks.url = "github:gmodena/nix-flatpak"; # Fork is being used until #24 merges
    # flatpaks.url = "github:Tomaszal/nix-flatpak/feature/overrides";

    # Used for theming the OS, see modules/home-manager/theme.nix
    nix-colors.url = "github:misterio77/nix-colors";

    # Necessary for modules/home-manager/programs/tmux.nix
    tmux-plugin-manager = {
      url = "github:tmux-plugins/tpm";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      create-host = (configs: builtins.listToAttrs (map
        (c: {
          name = c;
          value = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              inputs.home-manager.nixosModules.default
              (./. + ("/hosts/" + builtins.replaceStrings [ "@" ] [ "/" ] c) + /configuration.nix)
            ];
          };
        })
        configs));
    in
    {
      nixosConfigurations = (create-host [
        "desktop@default"
        "desktop@work"
      ]);
    };
}

