{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../secrets.nix
    ./gpu.nix

    ./impermanence.nix
    inputs.disko.nixosModules.disko
    ./disko.nix

    ./hardware-configuration.nix
  ];

  # GnuPG keyring
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    settings.default-cache-ttl = 3600 * 24;
  };

  # Yet another nix cli helper
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 3";
    flake = "/home/guz/Projects/dot013-nix";
  };

  # QMK keyboard
  hardware.keyboard.qmk.enable = true;
  services.udev.packages = with pkgs; [via vial];

  # Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Tailscale
  services.tailscale.enable = true;

  # Networking
  networking.hostName = "battleship";
  networking.networkmanager.enable = true;

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [53];
  networking.firewall.allowedTCPPorts = [80 433];

  # SSH
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "forced-commands-only";
  };

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
  services.xserver.xkb.layout = "br";
  console.keyMap = "br-abnt2";

  security.polkit.enable = true;

  # Nix
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
      "steam"
      "steam-unwrapped"
      "via"
      "vivaldi"
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
