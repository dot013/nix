{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix = {
      url = "github:nixos/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    capytalcc.url = "git+https://code.capytal.cc/capytal/capytal.cc";
    favelasmp.url = "git+https://code.capytal.cc/sixsides/favelasmp";
    guzone.url = "git+https://code.capytal.cc/dot013/guz.one";
    keikos.url = "git+https://code.capytal.cc/guz013/keikos.work";
    loreddev-gitea.url = "git+https://code.capytal.cc/loreddev/gitea?ref=release/v1.27-loreddev.0";

    affinty-nix = {
      url = "github:mrshmllow/affinity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

    neovim.url = "git+https://code.capytal.cc/dot013/nvim";

    obsidian-extensions = {
      url = "github:karaolidis/nix-obsidian-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
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
    # Modules that all other modules expect to be imported/available
    commonModules = [
      ({...}: {
        nix.settings.experimental-features = ["nix-command" "flakes"];
      })
      # "Cozy" Module
      ({
        config,
        lib,
        ...
      }: {
        options.nix.allowUnfreeList = lib.mkOption {
          type = with lib.types; listOf str;
          default = [];
        };
        config.nixpkgs.config.allowUnfreePredicate = p:
          builtins.elem (lib.getName p) config.nix.allowUnfreeList;
      })
      # Home-Manager setup
      ({pkgs-unstable, ...}: {
        imports = [
          inputs.home-manager.nixosModules.default
        ];
        home-manager.backupFileExtension = "bkp";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit inputs;
          inherit (inputs) self;
          inherit pkgs-unstable;
        };
      })
      # Stylix
      inputs.stylix.nixosModules.stylix
      ./style.nix
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
          system = pkgs.stdenv.hostPlatform.system;
        });
  in {
    lib = import ./lib {lib = nixpkgs.lib;};

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
        modules = [./hosts/dreadnought/configuration.nix] ++ commonModules;
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
        modules = [./hosts/battleship/configuration.nix] ++ commonModules;
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
        modules = [./hosts/fighter/configuration.nix] ++ commonModules;
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
        modules = [./hosts/infriltrator/configuration.nix] ++ commonModules;
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
        modules = [./hosts/spacestation/configuration.nix] ++ commonModules;
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
      services = {
        adguard = ./modules/services/adguard.nix;
        anubis = ./modules/services/anubis.nix;
        capytal-authelia = ./modules/services/capytal/authelia.nix;
        capytal-gitea = ./modules/services/capytal/gitea.nix;
        capytal-matrix = ./modules/services/capytal/matrix.nix;
        capytal-websites = ./modules/services/capytal/websites.nix;
        cloudflared = ./modules/services/cloudflared.nix;
        garage = ./modules/services/garage.nix;
        minecraft-servers = ./modules/services/minecraft-servers.nix;
        nextcloud = ./modules/services/nextcloud.nix;
        postgresql = ./modules/services/postgresql.nix;
        valkey = ./modules/services/valkey.nix;
      };
      features = {
        devkit = (import ./modules/features/devkit.nix).nixos;
        media = (import ./modules/features/media.nix).nixos;
        flatpak = (import ./modules/features/flatpak.nix).nixos;
        fonts = ./modules/features/fonts.nix;
        gaming = (import ./modules/features/gaming.nix).nixos;
        gnome = (import ./modules/features/gnome.nix).nixos;
        locale-brazil = ./modules/features/locale-brazil.nix;
        obsidian = (import ./modules/features/obsidian.nix).nixos;
        qmk-keyboard = ./modules/features/qmk-keyboard.nix;
        plymouth = ./modules/features/plymouth.nix;
        preservation = ./modules/features/preservation.nix;
        sddm = ./modules/features/sddm.nix;
        tailscale = ./modules/features/tailscale.nix;
      };
    };

    homeManagerModules = {
      features = {
        devkit = (import ./modules/features/devkit.nix).homeManager;
        media = (import ./modules/features/media.nix).homeManager;
        flatpak = (import ./modules/features/flatpak.nix).homeManager;
        gaming = (import ./modules/features/gaming.nix).homeManager;
        gnome = (import ./modules/features/gnome.nix).homeManager;
        obsidian = (import ./modules/features/obsidian.nix).homeManager;
        vesktop = ./modules/features/vesktop.nix;
        vivaldi = ./modules/features/vivaldi.nix;
        zen-browser = ./modules/features/zen-browser.nix;
      };
    };

    packages = forAllSystems ({
      lib,
      pkgs,
      system,
      ...
    }:
      with lib; let
        inherit (pkgs) callPackage;
      in {
        audacity = callPackage ./packages/audacity.nix {};
        infiltrator = self.nixosConfigurations."infiltrator".config.system.build.isoImage;
        playit-agent = callPackage ./packages/playit-agent.nix {};
        images = {
          nix-runner = callPackage ./packages/images/nix-runner.nix {nixSrc = inputs.nix;};
        };
        devkit = let
          callWrapper = p: as: callPackage p (as // {inherit (self.lib) wrapPackage;});
        in rec {
          ghostty = callWrapper ./packages/devkit/ghostty.nix {command = "${getExe zellij}";};
          git = callWrapper ./packages/devkit/git.nix {};
          lazygit = callWrapper ./packages/devkit/lazygit.nix {};
          lynx = callWrapper ./packages/devkit/lynx.nix {};
          starship = callWrapper ./packages/devkit/starship {};
          yazi = callWrapper ./packages/devkit/yazi {};
          zellij = callWrapper ./packages/devkit/zellij {
            neovim = inputs.neovim.packages.${system}.neovim;
            inherit git lazygit lynx starship yazi zsh;
          };
          zsh = callWrapper ./packages/devkit/zsh.nix {
            neovim = inputs.neovim.packages.${system}.neovim;
            inherit git lazygit lynx starship yazi;
          };
        };
      });

    devShells = forAllSystems ({
      lib,
      pkgs,
      system,
      ...
    }:
      with lib; {
        devkit = pkgs.mkShell {
          name = "devkit-shell";
          packages = with self.packages.${system}.devkit; [
            ghostty
            git
            lazygit
            lynx
            starship
            yazi
            zellij
            zsh
            inputs.neovim.packages.${system}.neovim
          ];
          shellHook = "${getExe self.packages.${system}.devkit.zsh}";
          EDITOR = "${getExe inputs.neovim.packages.${system}.neovim}";
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
            inputs.neovim.packages.${system}.neovim
          ];
        };
      });
  };
}
