{ pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/programs/hyprland.nix
  ];
  options.wm = { };
  config = {
    hyprland.enable = true;
    hyprland.monitors = [
      {
        name = "monitor1";
        resolution = "2560x1080";
        id = "HDMI-A-1";
      }
      {
        name = "monitor2";
        resolution = "1920x1080";
        id = "DVI-D-1";
        offset = "2560x0";
      }
    ];
    hyprland.workspaces = [
      {
        name = "1";
        monitor = "$monitor1";
        default = true;
      }
      {
        name = "2";
        monitor = "$monitor1";
      }
      {
        name = "3";
        monitor = "$monitor1";
      }
      {
        name = "4";
        monitor = "$monitor2";
        default = true;
      }
      {
        name = "5";
        monitor = "$monitor2";
      }
      {
        name = "6";
        monitor = "$monitor2";
      }
    ];
  };

}
