{
  inputs,
  pkgs,
  self,
  ...
} @ args: {
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  # Home Manager
  home-manager = {
    backupFileExtension = "bkp";
    extraSpecialArgs = {inherit (args) inputs self pkgs-unstable;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users."guz" = ./home.nix;
  };

  # Users
  users.users."guz" = {
    extraGroups = ["wheel" "guz"];
    isNormalUser = true;
    password = "1313";
    # hashedPasswordFile = builtins.toString config.sops.secrets."guz/password".path;
    shell = self.packages.${pkgs.stdenv.hostPlatform.system}.devkit.zsh;
  };
  users.groups."guz" = {};

  services.flatpak.enable = true;

  fonts.packages = with pkgs; [
    google-fonts
    nerd-fonts.fira-code
    self.packages.${pkgs.stdenv.hostPlatform.system}.cal-sans
  ];
  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;

  virtualisation.waydroid.enable = true;
  networking.nftables.enable = false;

  # Shell
  # programs.zsh.enable = true;

  # SDDM (Display Manager)
  services.displayManager.sddm = {
    enable = true;
    theme = "${pkgs.sddm-sugar-dark.override {}}/share/sddm/themes/sugar-dark";
    wayland.enable = true;
  };

  # GNOME (Desktop Manager)
  services.desktopManager.gnome = {
    enable = true;
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Mosh
  programs.mosh.enable = true;
  programs.mosh.openFirewall = true;

  # Steam
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;

  # Drawing Tablet
  hardware.opentabletdriver.enable = true;

  # OCI Containers
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.dockerSocket.enable = true;
  environment.systemPackages = with pkgs; [podman-compose];

  # Nix LD (Useful for devlopment)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
  ];

  # Nixpkgs
  nix.allowUnfreeList = [
    # "davinci-resolve"
    "obsidian"
    "steam"
    "steam-unwrapped"
    "via"
    "vivaldi"
  ];
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
