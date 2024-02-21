{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ../../modules/nixos/config/host.nix
    ../../modules/nixos/systems/set-user.nix
    ../../modules/nixos/systems/fonts.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./gpu-configuration.nix
  ];
  options.shared.configuration = { };
  config = {

    my-fonts.enable = true;
    my-fonts.user = "guz";
    my-fonts.fonts = with pkgs; [
      fira-code
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      (google-fonts.override { fonts = [ "Gloock" "Cinzel" ]; })
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

    environment.pathsToLink = [ " /share/zsh " ];

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    hardware.opentabletdriver.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;
  };
}

