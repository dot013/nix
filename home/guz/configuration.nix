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

  virtualisation.podman.enable = true;

  # Xbox Controller driver
  hardware.xone.enable = true;

  # OpenTabletDriver
  hardware.opentabletdriver.enable = true;
  services.udev.extraRules = ''
    KERNEL=="hidraw", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev"
  '';

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "davinci-resolve"
      "megasync"
      "reaper"
      "steam"
      "steam-unwrapped"
      "xow_dongle-firmware"
    ];
}
