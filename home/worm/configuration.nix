{
  lib,
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

  # Nixpkgs
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) ["via"];
}
