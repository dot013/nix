{
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../configuration.nix
    inputs.disko.nixosModules.disko
  ];

  # Network
  networking = {
    hostName = lib.mkForce "rusty";
    #wireless.enable = lib.mkForce true;
  };

  disko.devices.disk.main = {
    device = "/dev/sda"; # This will be overwritten by disko-install
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "500M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/efi";
            mountOptions = ["dmask=0022" "fmask=0022" "nofail"];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
}
