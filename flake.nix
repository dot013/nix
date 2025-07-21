{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      url = "git+https://forge.capytal.company/dot013/nvim";
    };

    rec-sh = {
      url = "git+https://forge.capytal.company/dot013/rec.sh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
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
      in
        f {
          inherit pkgs;
          inherit (pkgs) lib;
        });

    # Home manager NixOS module
    homeNixOSModules = [
      home-manager.nixosModules.home-manager
      ./style.nix
    ];
  in {
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
        modules =
          homeNixOSModules
          ++ [
            ./hosts/battleship/configuration.nix
            inputs.stylix.nixosModules.stylix
            ./home/guz/configuration.nix
          ];
      };
      "fighter" = nixpkgs.lib.nixosSystem rec {
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
            ./hosts/fighter/configuration.nix
            inputs.stylix.nixosModules.stylix
            ./home/guz-lite/configuration.nix
          ];
      };
    };

    homeConfigurations = forAllSystems ({pkgs, ...}: {
      "guz" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            system = pkgs.system;
            config.allowUnfreePredicate = _: true;
          };
          inherit inputs self;
        };
        modules = [
          inputs.stylix.homeManagerModules.stylix
          ./style.nix
          inputs.xremap.homeManagerModules.default
          ./home/guz
        ];
      };
      "guz-lite" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            system = pkgs.system;
            config.allowUnfreePredicate = _: true;
          };
          inherit inputs self;
        };
        modules = [
          inputs.stylix.homeManagerModules.stylix
          ./style.nix
          inputs.xremap.homeManagerModules.default
          ./home/guz-lite
        ];
      };
      "worm" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            system = pkgs.system;
            config.allowUnfreePredicate = _: true;
          };
          inherit inputs self;
        };
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
    };

    packages = forAllSystems ({
      lib,
      pkgs,
      ...
    }: {
      davincify = pkgs.callPackage ./packages/davincify {};
      untrack = pkgs.callPackage ./packages/untrack {};

      neovim = inputs.neovim.packages.${pkgs.system}.default;

      devkit =
        (import ./packages/devkit {inherit inputs pkgs;})
        // {
          neovim = self.packages.${pkgs.system}.neovim;
        };
      devkit-shell = let
        devkit = self.packages.${pkgs.system}.devkit;
        packages = with devkit; [
          git
          lazygit
          neovim
          starship
          tmux
          yazi
          zellij
          zsh

          # Useful on new Nix installations
          (pkgs.writeShellScriptBin "nix" ''
            ${lib.getExe pkgs.nix} \
              --experimental-features 'nix-command flakes' \
              "$@"
          '')
        ];
      in
        pkgs.writeShellScriptBin "devkit-shell" ''
          export PATH="$PATH:${lib.makeBinPath packages}"
          ${lib.getExe devkit.zsh} "$@"
        '';
    });

    devShells = forAllSystems ({
      lib,
      pkgs,
      ...
    }: {
      devkit = pkgs.mkShell {
        name = "devkit-shell";
        shellHook = "${lib.getExe self.packages.${pkgs.system}.devkit-shell}";
      };
      default = self.devShells.${pkgs.system}.devkit;
    });
  };
}
