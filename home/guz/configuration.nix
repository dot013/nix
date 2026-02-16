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

  # Backup environment
  services.desktopManager.gnome.enable = true;

  programs.java.enable = true;

  virtualisation.podman.enable = true;

  # Xbox Controller driver
  hardware.xone.enable = true;
  hardware.xpad-noone.enable = lib.mkForce false; # Build failure https://github.com/NixOS/nixpkgs/issues/467803

  # OpenTabletDriver
  hardware.opentabletdriver.enable = true;
  services.udev.extraRules = ''
    KERNEL=="hidraw", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev"
  '';

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "davinci-resolve"
      "reaper"
      "steam"
      "steam-unwrapped"
      "xow_dongle-firmware"
    ];

  nixpkgs.config.android_sdk.accept_license = true;
}
