{ config, lib, pkgs, ... }:

let
  cfg = config.wm;
  wm-boot = pkgs.writeShellScriptBin "wm-boot" ''
    eww="${pkgs.eww-wayland}/bin/eww"
    swww="${pkgs.swww}/bin/swww"

    if [[ "$($eww ping)" -ne "pong" ]]; then
      $eww daemon
    fi
    $eww close-all
    $eww open bar
    $eww open bar-2
    $eww reload

    $swww init
  '';
  wm-update = pkgs.writeShellScriptBin "wm-update" ''
    eww="${pkgs.eww-wayland}/bin/eww"
    swww="${pkgs.swww}/bin/swww"

    $eww reload

    $swww img "${builtins.toPath cfg.wallpaper}"
  '';
in
{
  imports = [
    ../../modules/home-manager/programs/hyprland.nix
    ../../modules/home-manager/programs/eww
  ];
  options.wm = with lib; with lib.types; {
    wallpaper = mkOption {
      default = ../../static/guz-wallpaper-default.webp;
      type = path;
    };
  };
  config = {

    eww.enable = true;

    hyprland.enable = true;

    hyprland.exec = [
      "${wm-boot}/bin/wm-boot"
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    ];
    home.activation = {
      wm-update = "${wm-update}/bin/wm-update";
    };

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

