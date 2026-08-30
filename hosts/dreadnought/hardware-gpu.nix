{pkgs, ...}: {
  services.xserver.videoDrivers = ["modesetting"];

  # AMD
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.amdgpu.initrd.enable = true;
  hardware.amdgpu.opencl.enable = true;

  environment.systemPackages = with pkgs; [clinfo];
}
