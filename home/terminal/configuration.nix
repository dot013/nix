{
  config,
  inputs,
  pkgs,
  pkgs-unstable,
  self,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  # User
  users.users."guz" = {
    extraGroups = ["wheel" "guz"];
    isNormalUser = true;
    hashedPasswordFile = builtins.toString config.sops.secrets."guz/password".path;
    shell = self.packages.${pkgs.stdenv.hostPlatform.system}.devkit.zsh;
  };
  users.groups."guz" = {};

  home-manager.backupFileExtension = "bkp";
  home-manager.extraSpecialArgs = {inherit inputs self pkgs-unstable;};
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users."guz" = ./home.nix;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  xdg.portal.xdgOpenUsePortal = true;
  xdg.portal.extraPortals = with pkgs; [xdg-desktop-portal-gtk];

  # Shell
  programs.zsh.enable = true;
}
