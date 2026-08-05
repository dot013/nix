{
  config,
  inputs,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
with lib; {
  imports = [
    inputs.preservation.nixosModules.preservation
  ];

  preservation.enable = true;
  preservation.preserveAt."/persist" = {
    directories =
      [
        "/etc/nixos"
        "/etc/NetworkManager/system-connections"
        "/etc/secureboot"
        "/var/db/sudo"
        "/var/keys"
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/power-profiles-daemon"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timers"
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
      ]
      # Garage
      ++ (with config.services.garage;
        optionals enable ([
            {
              directory = toString settings.metadata_dir;
              user = "garage";
              group = "garage";
              mode = "u=rwx,g=rx,o=";
            }
          ]
          ++ (
            if isPath settings.data_dir
            then toString settings.data_dir
            else
              map (dir: {
                directory = toString dir.path;
                user = "garage";
                group = "garage";
                mode = "u=rwx,g=rx,o=";
              })
              settings.data_dir
          )))
      # PostgreSQL
      ++ (optionals config.services.postgresql.enable [
        {
          directory = config.services.postgresql.dataDir;
          user = "postgres";
          group = "postgres";
          mode = "u=rwx,g=rx,o=";
        }
      ])
      # Tailscale
      ++ (optionals config.services.tailscale.enable [
        "/var/lib/tailscale"
      ]);
    files = [
      {
        file = "/etc/machine-id";
        inInitrd = true;
      }
      {
        file = "/etc/ssh/ssh_host_rsa_key";
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/etc/ssh/ssh_host_ed25519_key";
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/var/lib/systemd/random-seed";
        how = "symlink";
        inInitrd = true;
        configureParent = true;
      }
    ];
  };
  preservation.preserveAt."/persist".users = let
    isInstalledIn = ps: name:
      pipe ps [
        (map (p: getName p))
        unique
        (sort lessThan)
        (elem name)
      ];
  in
    mapAttrs (name: value: let
      isInstalled = name:
        elem true [
          (isInstalledIn value.home.packages name)
          (isInstalledIn config.environment.systemPackages name)
        ];
    in {
      directories =
        [
          "Documents"
          "Downloads"
          "Job"
          "Music"
          "Nextcloud"
          "Projects"
          "Pictures"
          "Videos"
          ".ssh"
          ".gnupg"
          ".local/share/keyrings"
          ".local/share/Trash"

          # SOPS
          ".config/sops/age"
        ]
        # Audacity
        ++ (optionals (isInstalled "audacity" || isInstalled "audacity4")) [
          ".cache/Audacity"
          ".config/Audacity"
          ".config/audacity4"
          ".local/share/Audacity"
          ".local/share/audacity4"
        ]
        # Blender
        ++ (optionals (isInstalled "blender")) [
          ".cache/blender"
          ".config/blender"
        ]
        # Direnv
        ++ (optionals (value.programs.direnv.enable)) [
          ".local/share/direnv"
          ## Go
          "go"
          ".cache/go-build"
          ".cache/gopls"
          ## PNPM
          ".cache/pnpm"
          ".local/share/pnpm"
          ".local/state/pnpm"
        ]
        # Flatpak
        ++ (optionals (
          config.services.flatpak.enable
          || (value.services?flatpak && value.services.flatpak.enable)
        )) [
          ".cache/flatpak"
          ".local/share/flatpak"
        ]
        # Godot
        ++ (optionals (isInstalled "godot")) [
          ".cache/godot"
          ".config/godot"
          ".local/share/godot"
        ]
        # Krita
        ++ (optionals (isInstalled "krita")) [
          "KritaRecorder"
          ".local/share/krita"
        ]
        # Inkscape
        ++ (optionals (isInstalled "inkscape")) [
          ".config/inkscape"
        ]
        # LazyGit
        ++ (optionals (value.programs.lazygit.enable)) [
          ".local/state/lazygit"
        ]
        # NVIM
        ++ (optionals (isInstalled "neovim")) [
          ".cache/nvim"
          ".config/nvim"
          ".local/share/nvim"
          ".local/state/nvim"
        ]
        # Starship
        ++ (optionals (value.programs.starship.enable || isInstalled "starship")) [
          ".cache/starship"
        ]
        # Steam
        ++ (optionals (
          value.programs.lutris.enable
          || config.programs.steam.enable
          || isInstalled "steam"
          || isInstalled "steam-unwrapped"
        )) [
          ".steam"
          ".local/share/Steam"
          ".local/share/Valve Corporation"
        ]
        # Vivaldi
        ++ (optionals (value.programs.vivaldi.enable || isInstalled "vivaldi")) [
          ".cache/vivaldi"
          ".config/vivaldi"
          ".local/lib/vivaldi"
        ]
        # Wezterm
        ++ (optionals value.programs.wezterm.enable) [
          ".cache/wezterm"
        ]
        ++ (optionals (!value.programs.wezterm.enable && isInstalled "wezterm")) [
          ".cache/wezterm"
          ".config/wezterm"
        ]
        # Zellij
        ++ (optionals value.programs.zellij.enable) [
          ".cache/zellij"
        ]
        ++ (optionals (!value.programs.zellij.enable && isInstalled "zellij")) [
          ".cache/zellij"
          ".config/zellij"
        ]
        # Zen Browser
        ++ (optionals value.programs.zen-browser.enable) [
          ".cache/zen"
          ".config/zen"
        ];
      files =
        []
        # Starship
        ++ (optionals (!value.programs.starship.enable && isInstalled "starship")) [
          ".config/starship.toml"
        ];
    }) (
      if config?home-manager
      then config.home-manager.users
      else {}
    );

  systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
}
