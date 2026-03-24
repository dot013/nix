{
  config,
  inputs,
  lib,
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

  users.users."guz" = {
    extraGroups = ["wheel" "guz"];
    isNormalUser = true;
    hashedPasswordFile = builtins.toString config.sops.secrets."guz/password".path;
    shell = self.packages.${pkgs.stdenv.hostPlatform.system}.devkit.zsh;
  };
  users.groups."guz" = {};

  # Shell
  programs.zsh.enable = true;

  services.displayManager.sddm = {
    enable = true;
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
    ];
    theme = "${pkgs.sddm-astronaut.override {embeddedTheme = "hyprland_kath";}}/share/sddm/themes/sddm-astronaut-theme";
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

  xdg.portal.xdgOpenUsePortal = true;
  xdg.portal.extraPortals = with pkgs; [xdg-desktop-portal-gtk];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
