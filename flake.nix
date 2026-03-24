{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "";
      inputs.home-manager.follows = "";
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    heart-modpack = {
      url = "git+ssh://gitea@spacestation/heart/modpack.git";
      # url = "git+file:///home/guz/.projects/heart-modpack";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    nix-minecraft = {
      url = "github:infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      url = "git+https://code.capytal.cc/dot013/nvim";
      # url = "git+file:///home/guz/.projects/dot013-nvim";
    };

    rec-sh = {
      url = "git+https://code.capytal.cc/dot013/rec.sh/?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
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
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfreePredicate = _: true;
        };
      in
        f {
          inherit pkgs pkgs-unstable;
          inherit (pkgs) lib;
        });

    # Home manager NixOS module
    homeNixOSModules = [
      home-manager.nixosModules.home-manager
      ./style.nix
    ];
  in {
    formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);

    nixosConfigurations = {
      "battleship" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
            config.allowUnfreePredicate = _: true;
          };
          inherit inputs self;
        };
        modules = [
          ./hosts/battleship-mk2/configuration.nix
          ./modules/nixos/context.nix
          ./home/terminal/configuration.nix
          inputs.stylix.nixosModules.stylix
          ./style.nix
        ];
      };
      "figther" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfreePredicate = _: true;
          };
          inherit inputs self;
        };
        modules =
          homeNixOSModules
          ++ [
            ./hosts/figther/configuration.nix
            inputs.stylix.nixosModules.stylix
            ./modules/nixos/context.nix
            ./home/guz-lite/configuration.nix
          ];
      };
      "rusty" = inputs.nixpkgs-2505.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfreePredicate = _: true;
          };
          inherit inputs self;
        };
        modules =
          [
            inputs.home-manager-2505.nixosModules.home-manager
            ./style.nix
          ]
          ++ [
            inputs.stylix-2505.nixosModules.stylix
            ./modules/nixos/context.nix
            ./hosts/rusty/configuration.nix
          ];
      };
      "virus" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfreePredicate = _: true;
          };
          inherit inputs self;
        };
        modules = [
          ./hosts/virus/configuration.nix
        ];
      };
      "infiltrator" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
            config.allowUnfreePredicate = _: true;
          };
          inherit inputs self;
        };
        modules = [
          ./hosts/infriltrator/configuration.nix
        ];
      };
    };

    homeConfigurations = forAllSystems ({
      pkgs,
      pkgs-unstable,
      ...
    }: {
      "guz" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs pkgs-unstable;
        modules = [
          inputs.stylix.homeManagerModules.stylix
          ./style.nix
          inputs.xremap.homeManagerModules.default
          ./home/guz
        ];
      };
      "guz-lite" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs pkgs-unstable;
        modules = [
          inputs.stylix.homeManagerModules.stylix
          ./style.nix
          inputs.xremap.homeManagerModules.default
          ./home/guz-lite
        ];
      };
      "worm" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs pkgs-unstable;
        modules = [
          ./home/worm
        ];
      };
    });

    nixosModules = {
      neovim = inputs.neovim.nixosModules.default;
    };

    homeManagerModules = {
      devkit = {
        lib,
        pkgs,
        stdenv,
        ...
      }: let
        devkitPkgs = self.packages.${pkgs.system}.devkit;
      in {
        imports = [
          ./modules/home-manager/devkit.nix
          self.homeManagerModules.neovim
        ];
        options._devkit = with lib; let
          mkPkgOption = pkg:
            mkOption {
              type = with types; package;
              default = pkg;
              readOnly = true;
            };
        in {
          packages = {
            ghostty = mkPkgOption devkitPkgs.ghostty;
            git = mkPkgOption devkitPkgs.git;
            lazygit = mkPkgOption devkitPkgs.lazygit;
            starship = mkPkgOption devkitPkgs.starship;
            yazi = mkPkgOption devkitPkgs.yazi;
            zellij = mkPkgOption devkitPkgs.zellij;
            tmux = mkPkgOption devkitPkgs.tmux;
            zsh = mkPkgOption devkitPkgs.zsh;
          };
        };
      };
      neovim = inputs.neovim.homeManagerModules.default;
      qutebrowser-profiles = ./modules/home-manager/qutebrowser-profiles.nix;
      zen-browser = ./modules/home-manager/zen-browser;
    };

    packages = forAllSystems ({
      lib,
      pkgs,
      ...
    }: {
      neovim = inputs.neovim.packages.${pkgs.system}.default;
      audacity = pkgs.callPackage ./packages/audacity.nix {};
      cal-sans = pkgs.callPackage ./packages/cal-sans.nix {};
      devkit = {
        ghostty = pkgs.callPackage ./packages/devkit/ghostty.nix {
          command = "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.devkit.zsh}";
        };
        git = pkgs.callPackage ./packages/devkit/git.nix {};
        lazygit = pkgs.callPackage ./packages/devkit/lazygit.nix {};
        starship = pkgs.callPackage ./packages/devkit/starship {};
        yazi = pkgs.callPackage ./packages/devkit/yazi {};
        zellij = pkgs.callPackage ./packages/devkit/zellij {};
        zsh = pkgs.callPackage ./packages/devkit/zsh {};
        neovim = self.packages.${pkgs.system}.neovim;
      };
    });

    devShells = forAllSystems ({
      lib,
      pkgs,
      ...
    }: {
      devkit = pkgs.mkShell {
        name = "devkit-shell";
        packages = with self.packages.${pkgs.stdenv.hostPlatform.system}.devkit; [
          ghostty
          git
          lazygit
          starship
          yazi
          zellij
          zsh
          neovim
        ];
        shellHook = "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.devkit.zsh}";
        EDITOR = "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.devkit.neovim}";
      };
      default = self.devShells.${pkgs.system}.devkit;
    });
  };
}
