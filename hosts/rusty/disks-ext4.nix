{
  disko.devices = {
    disk.main = {
      device = "/dev/sda"; # This will be overwritten by disko-install
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            label = "boot";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["defaults"];
            };
          };
          luks = {
            end = "-4G";
            label = "luks";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {crypttabExtraOpts = ["fido2-device=auto" "token-timeout=10"];};
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
          swap = {
            size = "100%";
            content = {
              type = "swap";
              randomEncryption = true;
              priority = 100;
              resumeDevice = true;
            };
          };
        };
      };
    };
  };
}
