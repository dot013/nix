{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dependecy of the Neovim configuration at ./modules/home-manager/devenv.nix
    dot013-nvim = {
      url = "github:dot013/nvim";
      # url = "git+file:///home/guz/.projects/dot013-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixpkgs-unstable,
    ...
  } @ inputs: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system: let
        pkgs = import nixpkgs {inherit system;};
      in
        f pkgs);

    # Shared NixOS modules
    nixosModules = [
      inputs.stylix.nixosModules.stylix
      home-manager.nixosModules.home-manager
      ./home.nix
    ];
  in {
    nixosConfigurations = {
      "battleship" = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs self;};
        modules =
          nixosModules
          ++ [
            ./hosts/battleship/configuration.nix
            ./hosts/battleship/home.nix
          ];
      };
      "fighter" = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs self;};
        modules =
          nixosModules
          ++ [
            ./hosts/fighter/configuration.nix
            ./hosts/fighter/home.nix
          ];
      };
    };

    homeConfigurations = {
      "guz" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {inherit inputs self;};
        modules = [
          inputs.stylix.homeManagerModules.stylix
          # inputs.xremap.homeManaggerModules.default
          ./home
        ];
        pkgs = import nixpkgs {system = "x86_64-linux";};
      };
    };

    homeManagerModules = {
      devenv = ./modules/home-manager/devenv.nix;
    };
  };
}
