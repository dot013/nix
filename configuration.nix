{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./secrets.nix
  ];

  # GnuPG keyring
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    settings = {default-cache-ttl = 3600 * 24;};
  };
  services.pcscd.enable = true;

  # Desktops

  ## Hyprland
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.hyprlock.enable = true;

  programs.xwayland.enable = true;

  ### Freedesktop providers

  #### Secrets
  services.gnome.gnome-keyring.enable = true;
  security.pam.services."gdm".enableGnomeKeyring = true;

  ### File picker and other portals not implemented by XDPH
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];

  services.xserver.displayManager.gdm.enable = true;

  # Yet another nix cli helper
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 3";
    flake = "/home/guz/.projects/dot013-nix";
  };

  # QMK keyboard
  hardware.keyboard.qmk.enable = true;
  services.udev.packages = [pkgs.via];

  # Enable Nix-LD for standalone binaries (useful for development)
  programs.nix-ld.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Audio
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber.enable = true;
  };
  security.rtkit.enable = true;
  services.pulseaudio.enable = lib.mkForce false;
  environment.systemPackages = with pkgs; [
    pwvucontrol
    via
  ];

  # Networking
  networking = {
    networkmanager.enable = true;
    nameservers = ["192.168.0.1" "9.9.9.9"];
  };

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [80 433];

  # SSH
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "forced-commands-only";
  };

  # Mosh
  programs.mosh.enable = true;
  programs.mosh.openFirewall = true;

  # Tailscale
  services.tailscale.enable = true;

  # Locale
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = let
    locale = "pt_BR.UTF-8";
  in {
    LC_ADDRESS = locale;
    LC_IDENTIFICATION = locale;
    LC_MEASUREMENT = locale;
    LC_MONETARY = locale;
    LC_NAME = locale;
    LC_NUMERIC = locale;
    LC_PAPER = locale;
    LC_TELEPHONE = locale;
    LC_TIME = locale;
  };

  # Keyboard
  services.xserver.xkb = {
    layout = "br";
  };
  console.keyMap = "br-abnt2";

  security.polkit.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Nix
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
