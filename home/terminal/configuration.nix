{
  config,
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

  # Shell
  programs.zsh.enable = true;

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

  # Drawing Tablet
  hardware.opentabletdriver.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
