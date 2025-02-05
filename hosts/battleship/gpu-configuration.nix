{
  config,
  pkgs,
  ...
}: {
  imports = [];

  services.xserver.videoDrivers = ["amdgpu"];

  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };

  boot.kernelModules = ["amdgpu"];
  boot.initrd.kernelModules = ["amdgpu"];

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    amdvlk
    rocmPackages.clr.icd
    vaapiVdpau
  ];
}
