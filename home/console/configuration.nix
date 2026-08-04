{
  inputs,
  pkgs,
  self,
  ...
} @ args: {
  imports = [
    inputs.home-manager.nixosModules.default

    self.nixosModules.features.gnome
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

  # Mosh
  programs.mosh.enable = true;
  programs.mosh.openFirewall = true;
}
