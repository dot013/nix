{pkgs, ...}: {
  hardware.keyboard.qmk.enable = true;
  services.udev.packages = with pkgs; [vial];
}
