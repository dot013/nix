{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declaratively install flatpaks
    flatpaks = {
      url = "github:gmodena/nix-flatpak"; # Fork is being used until #24 merges
    };
    # flatpaks.url = "github:Tomaszal/nix-flatpak/feature/overrides";

    # Used for theming the OS, see modules/home-manager/theme.nix
    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Necessary for modules/home-manager/programs/tmux.nix
    tmux-plugin-manager = {
      url = "github:tmux-plugins/tpm";
      flake = false;
    };

    rec-sh = {
      url = "github:dot013/rec.sh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dot013-environment = {
      # url = "git+file:///home/guz/.projects/dot013/environment";
      url = "git+https://forge.capytal.company/dot013/environment";
    };
    dot013-neovim = {
      # url = "git+file:///home/guz/.projects/dot013/nvim";
      url = "git+https://forge.capytal.company/dot013/nvim";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland?ref=v0.41.2";
      rev = "918d8340afd652b011b937d29d5eea0be08467f5";
      submodules = true;
    };
    xdg-desktop-portal-hyprland = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland/v1.3.2";
    };
    /*
    Note to self:
    The last commit with working screen share, as the time of writing this, was
    https://github.com/hyprwm/xdg-desktop-portal-hyprland/commit/6a5de92769d5b7038134044053f90e7458f6a197
    https://github.com/hyprwm/Hyprland/commit/3c964a9fdc220250a85b1c498e5b6fad9390272f
    so if needed, you can always roll-back.

    Fuck discord.
    */
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixpkgs-unstable,
    ...
  } @ inputs: let
    create-host = configs:
      builtins.listToAttrs (map
        (c: {
          name = c;
          value = nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs;};
            modules = [
              inputs.home-manager.nixosModules.default
              (./. + ("/hosts/" + builtins.replaceStrings ["@"] ["/"] c) + /configuration.nix)
            ];
          };
        })
        configs);
  in {
    nixosConfigurations = create-host [
      "battleship"
      "fighter"
      # "cruiser"
      # "spacestation"
    ];
  };
}
