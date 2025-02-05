{
  config,
  inputs,
  pkgs,
  self,
  ...
}: {
  # Home-manager configurations for when it is used as a NixOS module.

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bkp";
  home-manager.extraSpecialArgs = {inherit inputs self;};
  home-manager.users.guz = import ./home;

  stylix.enable = true;
  stylix.image = ./static/guz-wallpaper-default.png;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
}
