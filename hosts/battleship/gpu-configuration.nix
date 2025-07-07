{
  pkgs,
  inputs,
  ...
}: let
  pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.system};
in {
  imports = [];

  boot.kernelModules = ["amdgpu"];
  boot.initrd.kernelModules = ["amdgpu"];

  # services.xserver.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];

  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };

  hardware.graphics.enable = true;
  hardware.graphics.package = pkgs-hyprland.mesa;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.package32 = pkgs-hyprland.mesa;
  hardware.graphics.extraPackages = with pkgs; [
    # OpenCL
    rocmPackages.clr.icd
    rocmPackages.rocm-runtime
    rocmPackages.rocminfo
    amdvlk
  ];

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];
}
