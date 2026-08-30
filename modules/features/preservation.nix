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
      # LLDAP
      ++ (optionals config.services.lldap.enable [
        {
          directory = "/var/lib/lldap";
          user = "lldap";
          group = "lldap";
          mode = "u=rwx,g=rx,o=";
        }
      ])
      # Matrix Continuwuity
      ++ (optionals config.services.matrix-continuwuity.enable [
        {
          directory = config.services.matrix-continuwuity.settings.global.database_path;
          user = config.services.matrix-continuwuity.user;
          group = config.services.matrix-continuwuity.group;
          mode = "u=rwx,g=rx,o=";
        }
      ])
      # Mautrix Discord
      ++ (optionals (config.services.mautrix-discord.enable) [
        {
          directory = config.services.mautrix-discord.dataDir;
          user = "mautrix-discord";
          group = "mautrix-discord";
          mode = "u=rwx,g=rx,o=";
        }
      ])
      # Minecraft Servers
      ++ (optionals (config.services?minecraft-servers && config.services.minecraft-servers.enable) [
        {
          directory = config.services.minecraft-servers.dataDir;
          user = config.services.minecraft-servers.user;
          group = config.services.minecraft-servers.group;
          mode = "u=rwx,g=rx,o=";
        }
      ])
      # Nextcloud
      ++ (optionals (config.services.nextcloud.enable) [
        {
          directory = config.services.nextcloud.home;
          user = "nextcloud";
          group = "nextcloud";
          mode = "u=rwx,g=rx,o=";
        }
      ])
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
        ++ (optionals (isInstalled "affinity-v3"
          || isInstalled "affinity-photo"
          || isInstalled "affinity-designer"
          || isInstalled "affinity-publisher")) [
          ".local/share/affinity"
          ".local/share/affinity-v3"
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
        # Opencode
        ++ (optionals (isInstalled "opencode")) [
          ".cache/opencode"
          ".config/opencode"
          ".local/share/opencode"
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
        ]
        # ZSH
        ++ (optionals value.programs.zsh.enable) [
          ".local/state/zsh"
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

  systemd.services = {
    "garage".serviceConfig = mkIf config.services.garage.enable {
      User = "garage";
      Group = "garage";
      DynamicUser = mkForce false;
      StateDirectory = mkForce null;
    };
    "lldap".serviceConfig = mkIf config.services.lldap.enable {
      User = "lldap";
      Group = "lldap";
      DynamicUser = mkForce false;
      StateDirectory = mkForce null;
    };
    "continuwuity".serviceConfig = mkIf config.services.lldap.enable {
      DynamicUser = mkForce false;
    };
  };

  users.users = {
    "garage" = mkIf config.services.garage.enable {
      isSystemUser = true;
      group = "garage";
    };
    "lldap" = mkIf config.services.lldap.enable {
      isSystemUser = true;
      group = "lldap";
    };
  };
  users.groups = {
    "garage" = mkIf config.services.garage.enable {};
    "lldap" = mkIf config.services.lldap.enable {};
  };

  systemd.tmpfiles.rules =
    []
    ++ (optionals config.services.nextcloud.enable [
      "d ${config.services.nextcloud.home} 0750 nextcloud nextcloud -"
      "d ${config.services.nextcloud.home}/apps 0750 nextcloud nextcloud -"
      "d ${config.services.nextcloud.home}/config 0750 nextcloud nextcloud -"
      "d ${config.services.nextcloud.home}/data 0750 nextcloud nextcloud -"
    ]);

  systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
}
