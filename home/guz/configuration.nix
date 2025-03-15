{
  lib,
  pkgs,
  ...
}: {
  # Home-manager configurations for when it is used as a NixOS module.

  imports = [
    ../guz-lite/configuration.nix
  ];

  home-manager.users.guz = import ./default.nix;

  # Steam
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];

  # Xbox Controller driver
  hardware.xone.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "davinci-resolve"
      "steam"
      "steam-unwrapped"
    ];
}
