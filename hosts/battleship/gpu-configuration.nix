{pkgs, ...}: {
  imports = [];

  boot.kernelModules = ["amdgpu"];
  boot.initrd.kernelModules = ["amdgpu"];

  # services.xserver.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];

  # Configuration for davinci resolve based on
  # https://wiki.nixos.org/wiki/DaVinci_Resolve
  environment.variables = {
    RUSTICL_ENABLE = "radeonsi";
    ROC_ENABLE_PRE_VEGA = "1";
  };

  environment.systemPackages = with pkgs; [
    mesa-demos
    vulkan-tools
    clinfo
  ];

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [
    mesa
    libva
    libvdpau-va-gl
    vulkan-loader
    vulkan-validation-layers
    amdvlk
    mesa.opencl
  ];

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];
}
