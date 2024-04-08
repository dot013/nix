{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ../../modules/nih
    ../../modules/nixos/config/host.nix
    ../../modules/nixos/systems/set-user.nix
    ../../modules/nixos/systems/fonts.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./gpu-configuration.nix
  ];
  options.shared.configuration = {};
  config = {
    nih = {
      enable = true;
      ip = "192.168.1.13";
      handleDomains = false;
      networking = {
        interface = "enp6s0";
        wireless = false;
      };
      users.test = {
        username = "test";
      };

      serives = {
        tailscale.enable = true;
      };
      users.test = {
        programs.hyprland = {
          enable = true;
          exec = [
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          ];
          monitors = [
            {
              name = "monitor1";
              resolution = "2560x1080";
              id = "HDMI-A-1";
            }
            {
              name = "monitor2";
              resolution = "1920x1080";
              id = "DVI-D-1";
              offset = "2560x0";
            }
          ];
          windowRules = {
            "class:^(org.inkscape.Inkscape)$" = ["float"];
            "class:^(org.inkscape.Inkscape)$,title:(.*)(- Inkscape)$" = ["tile"];
          };
          workspaces = [
            # First monitor
            {
              name = "1";
              monitor = "$monitor1";
              default = true;
            }
            {
              name = "2";
              monitor = "$monitor1";
            }
            {
              name = "3";
              monitor = "$monitor1";
            }
            {
              name = "4";
              monitor = "$monitor1";
            }
            {
              name = "5";
              monitor = "$monitor1";
            }
            # Second monitor
            {
              name = "6";
              monitor = "$monitor2";
            }
            {
              name = "7";
              monitor = "$monitor2";
            }
            {
              name = "8";
              monitor = "$monitor2";
            }
            {
              name = "9";
              monitor = "$monitor2";
            }
            {
              name = "10";
              monitor = "$monitor2";
              default = true;
            }
          ];
        };

        programs.lf = {
          enable = true;
          settings = {
            preview = true;
            hidden = true;
            drawbox = true;
            icons = true;
            ignorecase = true;
          };
          keybindings = {
            "." = "set hidden!";
            "<enter>" = "open";
            "%" = "mkfile";
            d = "mkdir";
            D = "delete";
            ee = "editor-open";
          };
        };
      };
    };

    my-fonts.enable = true;
    my-fonts.user = "guz";
    my-fonts.fonts = with pkgs; [
      fira-code
      (nerdfonts.override {fonts = ["FiraCode"];})
      (google-fonts.override {fonts = ["Gloock" "Cinzel" "Red Hat Display"];})
      (stdenv.mkDerivation rec {
        pname = "calsans";
        version = "1.0.0";
        src = pkgs.fetchzip {
          url = "https://github.com/calcom/font/releases/download/v${version}/CalSans_Semibold_v${version}.zip";
          stripRoot = false;
          hash = "sha256-JqU64JUgWimJgrKX3XYcml8xsvy//K7O5clNKJRGaTM=";
        };
        installPhase = ''
          runHook preInstall
          install -m444 -Dt $out/share/fonts/truetype fonts/webfonts/*.ttf
          runHook postInstall
        '';
        meta = with lib; {
          homepage = "https://github.com/calcom/font";
          license = licenses.ofl;
          platforms = platforms.all;
        };
      })
    ];

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [];

    virtualisation.waydroid.enable = true;

    sops.defaultSopsFile = ../../secrets/desktop-secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.secrets.lon = {
      owner = config.users.users.guz.name;
    };
    sops.secrets.lat = {
      owner = config.users.users.guz.name;
    };

    sops.age.keyFile = "/home/guz/.config/sops/age/keys.txt";

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      portalPackage = inputs.xdg-desktop-portal-hyprland.packages."${pkgs.system}".xdg-desktop-portal-hyprland;
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
    ];

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };

    environment.systemPackages = with pkgs; [
      inputs.xdg-desktop-portal-hyprland.packages."${pkgs.system}".xdg-desktop-portal-hyprland
      inputs.hyprland.packages."${pkgs.system}".hyprland
      electron_28
      wlroots
      kitty
      rofi-wayland
      dunst
      libnotify
      swww
      sops
      wl-clipboard
    ];

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
      ];
    programs.steam = {
      enable = true;
    };

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    programs.zsh.enable = true;
    # Define a user account. Don't forget to set a password with ‘passwd’.

    services.flatpak.enable = true;

    environment.pathsToLink = [" /share/zsh "];

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    hardware.opentabletdriver.enable = true;

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;
    # hardware.pulseaudio.enable = true;

    services.interception-tools = let
      device = "/dev/input/by-id/usb-BY_Tech_Gaming_Keyboard-event-kbd";
    in {
      enable = true;
      plugins = [pkgs.interception-tools-plugins.caps2esc];
      udevmonConfig = ''
        - JOB: "${pkgs.interception-tools}/bin/intercept -g ${device} | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc -m 2 | ${pkgs.interception-tools}/bin/uinput -d ${device}"
          DEVICE:
            EVENTS:
              EV_KEY: [[KEY_CAPSLOCK, KEY_ESC]]
            LINK: ${device}
      '';
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
