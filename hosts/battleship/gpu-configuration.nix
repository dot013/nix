{
  config,
  pkgs,
  ...
}: {
  imports = [];
  options.shared.configuration.gpu = {};
  config = {
    boot.initrd.kernelModules = ["amdgpu"];
    services.xserver.videoDrivers = ["amdgpu"];

    environment = {
      variables = {
        ROC_ENABLE_PRE_VEGA = "1";
      };
      systemPackages = with pkgs; [
        clinfo
      ];
    };

    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [
        amdvlk
        rocmPackages.clr.icd
      ];
      driSupport = true;
      driSupport32Bit = true;
    };
  };
}
