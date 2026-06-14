{inputs, ...}: {
  imports = [
    inputs.preservation.nixosModules.preservation
  ];

  preservation.enable = true;
  preservation.preserveAt."/persist" = {
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/etc/secureboot"
      "/var/db/sudo"
      "/var/keys"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/power-profiles-daemon"
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/timers"
      "/var/lib/tailscale"
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
      {
        directory = "/var/lib/nixos";
        inInitrd = true;
      }
    ];
    files = [
      {
        file = "/etc/machine-id";
        inInitrd = true;
      }
      {
        file = "/etc/ssh/ssh_host_rsa_key";
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/etc/ssh/ssh_host_ed25519_key";
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/var/lib/systemd/random-seed";
        how = "symlink";
        inInitrd = true;
        configureParent = true;
      }
    ];
  };

  systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
}
