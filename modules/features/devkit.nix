{
  nixos = {
    config,
    inputs,
    lib,
    pkgs,
    self,
    ...
  }:
    with lib; let
      cfg = config.features.devkit;
      devkitPkgs = self.packages.${pkgs.stdenv.hostPlatform.system}.devkit;
    in {
      imports = [inputs.neovim.nixosModules.default];
      options.features.devkit = {
        full = mkEnableOption "";
      };
      config = {
        programs.gnupg.agent = {
          enable = true;
          pinentryPackage = pkgs.pinentry-gtk2;
          settings.default-cache-ttl = 3600 * 24;
        };

        # SSH
        services.openssh.enable = true;
        services.openssh.settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "forced-commands-only";
        };
        programs.mosh.enable = mkDefault true;

        services.ollama = {
          enable = cfg.full;
          package = pkgs.ollama-rocm;
          # loadModels = ["deepseek-r1:1.5b"];
        };

        # Nix LD (Useful for devlopment)
        programs.nix-ld.enable = true;
        programs.nix-ld.libraries = with pkgs; [stdenv.cc.cc];

        # OCI Containers
        virtualisation.podman.enable = true;
        virtualisation.podman.dockerCompat = true;
        virtualisation.podman.dockerSocket.enable = true;

        environment.systemPackages = with pkgs; [podman-compose];
        environment.shells = [
          (getExe devkitPkgs.zsh)
        ];
        environment.pathsToLink = ["/share/zsh"];
      };
    };

  homeManager = {
    config,
    inputs,
    lib,
    options,
    osConfig,
    pkgs,
    pkgs-unstable,
    self,
    ...
  }:
    with lib; let
      cfg = config.features.devkit;
      devkitPkgs = self.packages.${pkgs.stdenv.hostPlatform.system}.devkit;
    in {
      imports = [inputs.neovim.homeManagerModules.default];
      options.features.devkit = {
        full = mkOption {
          type = with types; bool;
          default = osConfig.features.devkit.full;
        };
      };
      config =
        {
          # Direnv
          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
          };

          # Ghostty
          programs.ghostty = {
            enable = true;
            systemd.enable = true;
            package = devkitPkgs.ghostty;
          };

          # Git
          programs.git = {
            enable = true;
            package = devkitPkgs.git;
            lfs.package = devkitPkgs.git;
          };

          # GPG Keyring
          programs.gpg = {
            enable = true;
            mutableKeys = true;
            mutableTrust = true;
          };

          # GPG Agent
          services.gpg-agent = {
            enable = true;
            defaultCacheTtl = 3600 * 24;
            pinentry.package = pkgs.pinentry-gtk2;
          };

          # Lazy
          programs.lazygit = {
            enable = true;
            package = devkitPkgs.lazygit;
          };

          # Neovim
          neovim.enable = true;

          # SSH
          programs.ssh = {
            enable = true;
            enableDefaultConfig = false;
            settings = {
              "*" = {
                ForwardAgent = false;
                AddKeysToAgent = "no";
                Compression = false;
                ServerAliveInterval = 0;
                ServerAliveCountMax = 3;
                HashKnownHosts = false;
                UserKnownHostsFile = "~/.ssh/known_hosts";
                ControlMaster = "no";
                ControlPath = "~/.ssh/master-%r@%n:%p";
                ControlPersist = "no";
              };
              "spacestation" = {
                hostname = "spacestation";
                identityFile = "${config.home.homeDirectory}/.ssh/spacestation";
              };
              "battleship" = {
                hostname = "battleship";
                identityFile = "${config.home.homeDirectory}/.ssh/battleship";
              };
              "fighter" = {
                hostname = "fighter";
                identityFile = "${config.home.homeDirectory}/.ssh/figther";
              };
            };
          };

          # Starship
          programs.starship = {
            enable = true;
            package = devkitPkgs.starship;
          };

          # Yazi
          programs.yazi = {
            enable = true;
            package = devkitPkgs.yazi;
            shellWrapperName = "y";
          };

          # Zellij
          programs.zellij = {
            enable = true;
            package = devkitPkgs.zellij;
          };

          ## ZSH
          programs.zsh = {
            enable = true;
            package = devkitPkgs.zsh;
            dotDir = "${config.xdg.configHome}/zsh";
          };

          # Godot
          home.packages = with pkgs-unstable;
            [
              devkitPkgs.lynx
            ]
            ++ optionals cfg.full [
              godot
              opencode
            ];

          home.file = let
            godotname = builtins.replaceStrings ["-"] ["."] pkgs-unstable.godot-export-templates-bin.version;
          in {
            ".local/share/godot/export_templates/${godotname}" = mkIf cfg.full {
              source = "${pkgs-unstable.godot-export-templates-bin}/share/godot/export_templates/${godotname}";
            };
          };

          xdg.configFile."opencode/opencode.json" = mkIf cfg.full {
            text = toJSON {
              "$schema" = "https://opencode.ai/config.json";
              model = "ollama/qwen3-coder:30b";
              provider = {
                ollama = {
                  npm = "@ai-sdk/openai-compatible";
                  name = "Ollama (local)";
                  options = {
                    baseURL = "http://localhost:${toString osConfig.services.ollama.port}/v1";
                  };
                  models = {
                    "deepseek-r1:1.5b" = {
                      name = "Deepseek R1";
                    };
                    "qwen3-coder:30b" = {
                      name = "Quen3 Coder";
                    };
                  };
                };
              };
            };
          };

          home.sessionVariables = {
            EXPLORER = "${getExe config.programs.yazi.package}";
            SHELL = "${getExe config.programs.zsh.package}";
            TERM = "xterm-256color";
            TERMINAL = "${getExe config.programs.ghostty.package}";
          };
        }
        // (optionalAttrs (options.services?flatpak) {
          services.flatpak.packages = [
            "com.authormore.penpotdesktop"
            "com.vscodium.codium"
          ];
        });
    };
}
