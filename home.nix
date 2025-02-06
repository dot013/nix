{
  inputs,
  pkgs,
  self,
  ...
}: {
  # Home-manager configurations for when it is used as a NixOS module.
  imports = [
    inputs.stylix.nixosModules.stylix
    ./colors.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bkp";
  home-manager.extraSpecialArgs = {inherit inputs self;};
  home-manager.users.guz = import ./home;

  programs.zsh.enable = true;
  users.users."guz".shell = pkgs.zsh;

}
