{
  nixos = {
    lib,
    pkgs,
    self,
    ...
  }:
    with lib; let
      devkitPkgs = self.packages.${pkgs.stdenv.hostPlatform.system}.devkit;
    in {
      imports = [self.nixosModules.neovim];

      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-gtk2;
        settings.default-cache-ttl = 3600 * 24;
      };

      programs.mosh.enable = mkDefault true;

      environment.shells = [
        (getExe devkitPkgs.zsh)
      ];
      environment.pathsToLink = ["/share/zsh"];
    };

  homeManager = {
    config,
    inputs,
    lib,
    pkgs,
    pkgs-unstable,
    self,
    ...
  }:
    with lib; let
      devkitPkgs = self.packages.${pkgs.stdenv.hostPlatform.system}.devkit;
    in {
      imports = [self.homeManagerModules.neovim];

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

      # Godot
      home.packages = [pkgs-unstable.godot];

      home.file = let
        godotname = builtins.replaceStrings ["-"] ["."] pkgs-unstable.godot-export-templates-bin.version;
      in {
        ".local/share/godot/export_templates/${godotname}" = {
          source = "${pkgs-unstable.godot-export-templates-bin}/share/godot/export_templates/${godotname}";
        };
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

      home.sessionVariables = {
        EXPLORER = "${getExe config.programs.yazi.package}";
        SHELL = "${getExe config.programs.zsh.package}";
        TERM = "xterm-256color";
        TERMINAL = "${getExe config.programs.ghostty.package}";
      };
    };
}
