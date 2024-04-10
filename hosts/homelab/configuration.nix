# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/nixos
    ./services.nix
    ./secrets.nix
    ./hardware-configuration.nix
  ];

  programs.nih.enable = true;
  programs.nih.flakeDir = "/home/guz/.nix";
  programs.nih.host = "homelab";

  profiles.locale.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
    settings = {
      default-cache-ttl = 3600 * 24;
    };
  };

  home-manager-helper.enable = true;
  home-manager-helper.users."guz" = {
    name = "guz";
    shell = pkgs.zsh;
    hashedPasswordFile = builtins.toString config.sops.secrets."guz/password".path;
    home = import ./home.nix;
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
  };

  environment.sessionVariables = {
    EDITOR = "nvim";
  };

  environment.systemPackages = with pkgs; [
    git
  ];

  programs.zsh.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking = {
    networkmanager.enable = true;
    hostName = "homelab";
    wireless.enable = false;
    dhcpcd.enable = true;
    defaultGateway = "192.168.1.1";
    interfaces."eno1".ipv4.addresses = [
      {
        address = "192.168.1.10";
        prefixLength = 24;
      }
    ];
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
