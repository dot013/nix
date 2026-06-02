{
  # Bootloader
  boot.supportedFilesystems = ["zfs"];

  boot.zfs.requestEncryptionCredentials = true;
  boot.zfs.forceImportRoot = false;
  boot.zfs.devNodes = "/dev/disk/by-id/";

  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "monthly";

  disko.devices = {
    disk = let
      mkDisk = device: mountpoint: {
        type = "disk";
        device = device;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = mountpoint;
                mountOptions = ["nofail"];
              };
            };
            zfs = {
              end = "-4G";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
          };
        };
      };
    in {
      root = mkDisk "/dev/sda" "/boot";
      mirror = mkDisk "/dev/sdb" "/boot-fallback";
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          acltype = "posixacl";
          dnodesize = "auto";
          canmount = "off";
          xattr = "sa";
          relatime = "on";
          normalization = "formD";
          mountpoint = "none";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };
        datasets = {
          "root" = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "prompt";
              compression = "zstd";
            };
            mountpoint = "/";
            postCreateHook = "zfs snapshot zroot/root@blank";
          };
          "nix" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/nix";
              compression = "zstd";
            };
            mountpoint = "/nix";
          };
          "persist" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/persist";
              compression = "zstd";
            };
            mountpoint = "/persist";
          };
          "s3" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/garage/data";
              compression = "lz4";
              "com.sun:auto-snapshot" = "false"; # S3/Garage already snapshots
            };
            mountpoint = "/var/lib/garage/data";
          };
        };
      };
    };
  };

  fileSystems."/" = {
    device = "zroot/root";
    fsType = "zfs";
    neededForBoot = true;
    options = ["zfsutil"];
  };
  fileSystems."/nix" = {
    device = "zroot/nix";
    fsType = "zfs";
    neededForBoot = true;
    options = ["zfsutil"];
  };
  fileSystems."/persist" = {
    device = "zroot/persist";
    fsType = "zfs";
    neededForBoot = true;
    options = ["zfsutil"];
  };
  fileSystems."/var/lib/garage/data" = {
    device = "zroot/s3";
    fsType = "zfs";
    options = ["zfsutil"];
  };
}
