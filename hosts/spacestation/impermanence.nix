{inputs, ...}: {
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
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/tailscale"
      "/var/lib/garage"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
