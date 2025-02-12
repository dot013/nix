{
  config,
  inputs,
  pkgs,
  self,
  ...
}: {
  # Users
  users.users."guz" = {
    useDefaultShell = true;
    isNormalUser = true;

    hashedPasswordFile = builtins.toString config.sops.secrets."guz/password".path;
    extraGroups = ["wheel" "guz"];
  };
  users.groups."guz" = {};

  # Home-manager configurations for when it is used as a NixOS module.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bkp";
  home-manager.extraSpecialArgs = {inherit inputs self;};
  home-manager.users.guz = import ./default.nix;

  services.flatpak.enable = true;

  programs.zsh.enable = true;
  users.users."guz".shell = pkgs.zsh;

  # Xremap run-as-user
  hardware.uinput.enable = true;
  users.groups.uinput.members = ["guz"];
  users.groups.input.members = ["guz"];
}
