{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = ["guz"];

  boot.kernelParams = ["kvm.enable_virt_at_load=0"];

  programs.dconf.enable = true;

  users.users."guz".extraGroups = ["libvirtd"];
  users.users."guz".packages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    adwaita-icon-theme
    quickemu
  ];

  # virtualisation.libvirtd = {
  #   enable = true;
  #   qemu = {
  #     swtpm.enable = true;
  #     ovmf.enable = true;
  #     ovmf.packages = [pkgs.OVMFFull.fd];
  #   };
  # };
  # virtualisation.spiceUSBRedirection.enable = true;
}
