{
  config,
  lib,
  modulesPath,
  ...
}:
with lib; {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_acpi"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  swapDevices = [];

  nixpkgs.hostPlatform = mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
}
