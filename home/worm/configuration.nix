{
  config,
  lib,
  inputs,
  pkgs,
  pkgs-unstable,
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
  home-manager.extraSpecialArgs = {inherit inputs self pkgs-unstable;};
  home-manager.users.guz = lib.mkDefault (import ./default.nix);

  programs.zsh.enable = true;
  users.users."guz".shell = pkgs.zsh;

  # Podman (not necessarily user-specific, but environment specific)
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.extraPackages = with pkgs; [
    podman-compose
  ];
}
