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

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
    rocmPackages.clr.icd
    vaapiVdpau
  ];
}
