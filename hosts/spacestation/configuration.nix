{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../secrets.nix
    ./impermanence.nix
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
    ./services.nix
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

  # Tailscale
  services.tailscale.enable = true;

  # Networking
  networking.hostName = "spacestation";
  networking.networkmanager.enable = true;
  networking.hostId = builtins.substring 0 8 (
    builtins.hashString "sha256" config.networking.hostName
  );

  # Firewall
  networking.firewall.enable = true;

  # SSH
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "forced-commands-only";
  };

  # Mosh
  programs.mosh.enable = true;

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

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.mirroredBoots = [
    {
      devices = ["nodev"];
      path = "/boot";
      efiSysMountPoint = "/boot";
    }
    {
      devices = ["nodev"];
      path = "/boot-fallback";
      efiSysMountPoint = "/boot-fallback";
    }
  ];
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.initrd.systemd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
