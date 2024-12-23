{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.dot013-environment.nixosModules.default
    ../../modules/nixos
    ./secrets.nix
    ./gpu-configuration.nix
    ./hardware-configuration.nix
  ];

  dot013.environment.enable = true;
  dot013.environment.interception-tools.devices = [
    "/dev/input/by-id/usb-BY_Tech_Gaming_Keyboard-event-kbd"
    "/dev/input/by-id/usb-Compx_2.4G_Wireless_Receiver-event-kbd"
  ]; # dot013.environment.interception-tools.device = "/dev/input/by-id/usb-Compx_2.4G_Wireless_Receiver-event-kbd";

  programs.nh.enable = true;
  programs.nh.flake = "/home/guz/nix";

  profiles.locale.enable = true;

  hardware.opentabletdriver.enable = true;
  # services.xserver.digimend.enable = true;
  services.libinput.enable = true;
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev"
  '';

  virtualisation.docker.enable = true;

  programs.dconf.enable = true;

  programs.hyprland.enable = true;
  /*
  # TEMPFIX: 2024-05-04 https://github.com/NixOS/nixpkgs/issues/308287#issuecomment-2093091892
  # After the flake update in 2024-05-04, the screen blacked out after switch
  programs.hyprland.envVars.enable = lib.mkForce false;
  */

  services.xserver = {
    enable = true;
  };
  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
  };

  services.xserver.videoDrivers = ["amdgpu"];
  boot.kernelModules = ["amdgpu"];
  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      libvdpau-va-gl
      rocmPackages.clr.icd
      vaapiVdpau
    ];
  };

  programs.steam.enable = true;
  programs.steam.wayland = true;
  programs.gamemode.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
    settings = {
      default-cache-ttl = 3600 * 24;
    };
  };

  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];

  services.tailscale = {
    enable = true;
    tailnetName = "${config.battleship-secrets.tailnet-name}";
  };

  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    fira-code
    (nerdfonts.override {fonts = ["FiraCode"];})
  ];

  home-manager-helper.enable = true;
  home-manager-helper.users."guz" = {
    name = "guz";
    shell = pkgs.zsh;
    hashedPasswordFile = builtins.toString config.sops.secrets."guz/password".path;
    home = import ./home.nix;
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "plugdev"];
    openssh.authorizedKeys.keyFiles = [
      ../../.ssh/guz-battleship.pub
    ];
  };

  environment.systemPackages = with pkgs;
    [
      git
      libinput
      polkit_gnome
    ]
    ++ (builtins.map (p: pkgs."${p}") config.battleship-secrets.lesser.packages);

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  # hardware.pulseaudio.enable = true;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
  nix.package = pkgs.nixVersions.nix_2_21;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [];

  programs.kdeconnect.enable = true;

  networking = {
    networkmanager.enable = true;
    hostName = "battleship";
    wireless.enable = false;
    dhcpcd.enable = true;
    defaultGateway = "${config.battleship-secrets.lesser.devices.defaultGateway}";
    interfaces."enp6s0".ipv4.addresses = [
      {
        address = "${config.battleship-secrets.lesser.devices.battleship}";
        prefixLength = 24;
      }
    ];
    nameservers = ["9.9.9.9"];
    firewall = let
      kde-connect = {
        from = 1714;
        to = 1764;
      };
    in {
      enable = true;
      allowedTCPPortRanges = [kde-connect];
      allowedUDPPortRanges = [kde-connect];
    };
  };
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    #jack.enable = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "forced-commands-only";
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
