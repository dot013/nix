{pkgs, ...}: {
  services.xserver.videoDrivers = ["amdgpu"];

  boot.kernelModules = ["amdgpu"];
  boot.initrd.kernelModules = ["amdgpu"];

  # AMD
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.amdgpu.opencl.enable = true;

  environment.systemPackages = with pkgs; [clinfo];
  environment.variables.ROC_ENABLE_PRE_VEGA = "1";

  # Configuration for davinci resolve based on
  # https://wiki.nixos.org/wiki/DaVinci_Resolve
  environment.variables.RUSTICL_ENABLE = "radeonsi";
  hardware.graphics.extraPackages = with pkgs; [mesa.opencl];

  systemd.tmpfiles.rules = let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combuned";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];
}
