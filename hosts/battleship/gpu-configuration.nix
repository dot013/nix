{pkgs, ...}: {
  imports = [];

  boot.kernelModules = ["amdgpu"];
  boot.initrd.kernelModules = ["amdgpu"];

  # services.xserver.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];

  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [
    # OpenCL
    rocmPackages.clr.icd
    clinfo
  ];
}
