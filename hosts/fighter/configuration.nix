{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
  ];

  users.users."guz" = {
    openssh.authorizedKeys.keyFiles = [
      ../../.ssh/guz-fighter.pub
    ];
  };

  # Hyprland compatibility
  programs.hyprland.package = lib.mkForce (pkgs.hyprland.override {
    legacyRenderer = true;
  });

  # Enable OpenGL
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    onevpl-intel-gpu
  ];

  # Laptop features
  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchExternalPower = "lock";

  # Network
  networking = {
    hostName = lib.mkForce "fighter";
    # wireless.enable = lib.mkForce true;
  };
}
