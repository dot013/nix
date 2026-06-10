{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/etc/secureboot"
      "/var/db/sudo"
      "/var/keys"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/tailscale"
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  boot.initrd.systemd = {
    services.impermanence-btrfs-rolling-root = {
      description = "Impermanence script for btrfs on boot";
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "journal+console";
      };
      requiredBy = ["initrd.target"];
      before = ["sysroot.mount"];
      requires = ["initrd-root-device.target"];
      after = ["initrd-root-device.target" "local-fs-pre.target"];
      script = ''
        mkdir -p /btrfs_tmp

        mount -o subvol=/ /dev/mapper/cryptroot /btrfs_tmp

        if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
        }

        for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
        done

        btrfs subvolume create /btrfs_tmp/root
        umount /btrfs_tmp
      '';
    };
    extraBin = {
      "mkdir" = lib.getExe' pkgs.coreutils "mkdir";
      "date" = lib.getExe' pkgs.coreutils "date";
      "stat" = lib.getExe' pkgs.coreutils "stat";
      "mv" = lib.getExe' pkgs.coreutils "mv";
      "find" = lib.getExe' pkgs.findutils "find";
      "btrfs" = lib.getExe' pkgs.btrfs-progs "btrfs";
    };
  };

  # boot.initrd.postResumeCommands = let
  #   # https://github.com/nix-community/impermanence?tab=readme-ov-file#btrfs-subvolumes
  #   script = pkgs.writeShellScriptBin "rollback" ''
  #     mkdir -p /btrfs_tmp
  #
  #     mount -o subvol=/ /dev/mapper/cryptroot /btrfs_tmp
  #
  #     if [[ -e /btrfs_tmp/root ]]; then
  #       mkdir -p /btrfs_tmp/old_roots
  #       timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
  #       mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
  #     fi
  #
  #     delete_subvolume_recursively() {
  #       IFS=$'\n'
  #       for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
  #         delete_subvolume_recursively "/btrfs_tmp/$i"
  #       done
  #       btrfs subvolume delete "$1"
  #     }
  #
  #     for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
  #       delete_subvolume_recursively "$i"
  #     done
  #
  #     btrfs subvolume create /btrfs_tmp/root
  #     umount /btrfs_tmp
  #   '';
  # in "${builtins.readFile (lib.getExe script)}";
}
