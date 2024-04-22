{
  config,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../../modules/nixos
  ];

  profiles.locale.enable = true;

  programs.hyprland.enable = true;
  services.xserver = {
    enable = true;
    displayManager = {
      sddm.enable = true;
    };
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
    settings = {
      default-cache-ttl = 3600 * 24;
    };
  };

  services.tailscale = {
    enable = true;
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
    initialPassword = "0000";
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

  environment.pathsToLink = [" /share/zsh "];

  programs.zsh.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.package = pkgs.nixVersions.nix_2_21;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [];

  networking = {
    hostName = "cruiser";
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
    #jack.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.hostPlatform = "x86_64-linux";
}
