{
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix

    ./home.nix
  ];

  users.users."guz" = {
    openssh.authorizedKeys.keyFiles = [
      ../../.ssh/guz-figther.pub
    ];
  };

  # Xremap run-as-user
  hardware.uinput.enable = true;
  users.groups.uinput.members = ["guz"];
  users.groups.input.members = ["guz"];

  # Enable OpenGL
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    vpl-gpu-rt
  ];

  # Laptop features
  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchExternalPower = "lock";

  # Network
  networking = {
    hostName = lib.mkForce "figther";
    nameservers = ["192.168.0.110"];
    # wireless.enable = lib.mkForce true;
  };
}
