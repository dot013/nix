{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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

    preservation.url = "github:nix-community/preservation";

    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # heart-modpack = {
    #   url = "git+ssh://gitea@spacestation/heart/modpack.git";
    #   # url = "git+file:///home/guz/.projects/heart-modpack";
    # };
    favelasmp.url = "git+ssh://gitea@100.98.115.36/sixsides/favelasmp";
    guzone.url = "git+https://code.capytal.cc/dot013/guz.one";
    keikos.url = "git+https://code.capytal.cc/guz013/keikos.work";
    loreddev-gitea.url = "git+https://code.capytal.cc/loreddev/gitea";

    nix-minecraft = {
      url = "github:infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    geysermc-velocity = {
      url = "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/velocity";
      flake = false;
    };
    floodgate-velocity = {
      url = "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/velocity";
      flake = false;
    };

    neovim = {
      url = "git+https://code.capytal.cc/dot013/nvim";
      # url = "git+file:///home/guz/.projects/dot013-nvim";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake?rev=101d6731d7b163ef4f6fab8c6eea7da4ddb52ec3";
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
    nixpkgsUnfree = {
      config,
      lib,
      ...
    }:
      with lib; let
        list = config.nix.allowUnfreeList;
      in {
        options.nix.allowUnfreeList = mkOption {
          type = with types; listOf str;
          default = [];
        };
        config.nixpkgs.config.allowUnfreePredicate = p:
          builtins.elem (getName p) list;
      };
    commonModules = [nixpkgsUnfree];
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
          system = pkgs.stdenv.hostPlatform.system;
        });
  in {
    formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);

    nixosConfigurations = {
      "dreadnought" = nixpkgs.lib.nixosSystem rec {
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
          [
            ./hosts/dreadnought/configuration.nix
            ./home/terminal/configuration.nix
            inputs.stylix.nixosModules.stylix
            ./style.nix
          ]
          ++ commonModules;
      };
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
          [
            ./hosts/battleship/configuration.nix
            ./home/worm/configuration.nix
            {users.users."guz".openssh.authorizedKeys.keyFiles = [./.ssh/battleship.pub];}
          ]
          ++ commonModules;
      };
      "fighter" = nixpkgs.lib.nixosSystem rec {
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
          [
            ./hosts/fighter/configuration.nix
            ./home/terminal/configuration.nix
            inputs.stylix.nixosModules.stylix
            ./style.nix
          ]
          ++ commonModules;
      };
      "rusty" = nixpkgs.lib.nixosSystem rec {
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
          [
            ./hosts/lost-home/configuration.nix
            ./home/terminal/configuration.nix
            inputs.stylix.nixosModules.stylix
            ./style.nix
          ]
          ++ commonModules;
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
        modules =
          [
            ./hosts/infriltrator/configuration.nix
          ]
          ++ commonModules;
      };
      "spacestation" = nixpkgs.lib.nixosSystem rec {
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
          [
            ./hosts/spacestation/configuration.nix
            ./home/worm/configuration.nix
            {users.users."guz".openssh.authorizedKeys.keyFiles = [./.ssh/spacestation.pub];}
          ]
          ++ commonModules;
      };
    };

    homeConfigurations = forAllSystems ({
      pkgs,
      pkgs-unstable,
      ...
    }: {
      "terminal" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs pkgs-unstable;
        modules = [
          ./home/terminal/home.nix
        ];
      };
      "worm" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs pkgs-unstable;
        modules = [
          ./home/worm/home.nix
        ];
      };
    });

    diskoConfigurations = {
      "battleship" = import ./hosts/battleship/disko.nix;
      "dreadnought" = import ./hosts/dreadnought/disko.nix;
    };

    nixosModules = {
      cloudflared-caddy = ./modules/cloudflared-caddy.nix;
      neovim = inputs.neovim.nixosModules.default;
      playit = ./modules/playit.nix;
      services = {
        adguard = ./services/adguard.nix;
        capytal-gitea = ./services/capytal/gitea.nix;
        cloudflared = ./services/cloudflared.nix;
        garage = ./services/garage.nix;
        minecraft-servers = ./services/minecraft-servers.nix;
        nextcloud = ./services/nextcloud.nix;
      };
    };

    homeManagerModules = {
      devkit = {...}: {
        imports = [
          self.homeManagerModules.neovim
          ./modules/home-manager/devkit.nix
        ];
      };
      godot = ./modules/home-manager/godot.nix;
      neovim = inputs.neovim.homeManagerModules.default;
    };

    packages = forAllSystems ({
      lib,
      pkgs,
      system,
      ...
    }: rec {
      playit-agent = pkgs.callPackage ./packages/playit-agent.nix {};
      audacity = pkgs.callPackage ./packages/audacity.nix {};
      cal-sans = pkgs.callPackage ./packages/cal-sans.nix {};
      devkit = {
        ghostty = pkgs.callPackage ./packages/devkit/ghostty.nix {
          command = "${lib.getExe devkit.zsh}";
        };
        git = pkgs.callPackage ./packages/devkit/git.nix {};
        lazygit = pkgs.callPackage ./packages/devkit/lazygit.nix {};
        starship = pkgs.callPackage ./packages/devkit/starship {};
        yazi = pkgs.callPackage ./packages/devkit/yazi {};
        zellij = pkgs.callPackage ./packages/devkit/zellij {};
        zsh = pkgs.callPackage ./packages/devkit/zsh {};
        neovim = self.packages.${system}.neovim;
      };
      neovim = inputs.neovim.packages.${system}.default;
      infiltrator = self.nixosConfigurations."infiltrator".config.system.build.isoImage;
    });

    devShells = forAllSystems ({
      lib,
      pkgs,
      system,
      ...
    }: {
      devkit = pkgs.mkShell {
        name = "devkit-shell";
        packages = with self.packages.${system}.devkit; [
          ghostty
          git
          lazygit
          starship
          yazi
          zellij
          zsh
          neovim
        ];
        shellHook = "${lib.getExe self.packages.${system}.devkit.zsh}";
        EDITOR = "${lib.getExe self.packages.${system}.devkit.neovim}";
      };
      default = pkgs.mkShell {
        name = "devkit-shell";
        packages = with self.packages.${system}.devkit; [
          ghostty
          git
          lazygit
          starship
          yazi
          zellij
          zsh
          neovim
        ];
        shellHook = ''
          echo '${lib.toJSON {
            workspace = {
              library = ["${pkgs.hyprland}/share/hypr/stubs"];
            };
          }}' > ./.luarc.json

        '';
      };
    });
  };
}
