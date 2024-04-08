{
  config,
  lib,
  pkgs,
  ...
}: let
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
in {
  imports = [
    ../../modules/home-manager/programs/hyprland.nix
    ../../modules/home-manager/programs/eww
  ];
  options.wm = with lib;
  with lib.types; {
    wallpaper = mkOption {
      default = ../../static/guz-wallpaper-default.png;
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
    hyprland.windowRules = {
      "class:^(org.inkscape.Inkscape)$" = ["float"];
      "class:^(org.inkscape.Inkscape)$,title:(.*)(- Inkscape)$" = ["tile"];
    };
    hyprland.workspaces = [
      # First monitor
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
        monitor = "$monitor1";
      }
      {
        name = "5";
        monitor = "$monitor1";
      }
      # Second monitor
      {
        name = "6";
        monitor = "$monitor2";
      }
      {
        name = "7";
        monitor = "$monitor2";
      }
      {
        name = "8";
        monitor = "$monitor2";
      }
      {
        name = "9";
        monitor = "$monitor2";
      }
      {
        name = "10";
        monitor = "$monitor2";
        default = true;
      }
    ];

    xdg.desktopEntries = {
      librewolf = {
        name = "Librewolf";
        genericName = "Web Browser";
        exec = "${pkgs.librewolf}/bin/librewolf %U";
        terminal = false;
        categories = ["Application" "Network" "WebBrowser"];
        mimeType = ["text/html" "text/xml"];
      };
      davinci = {
        name = "Davinci Resolve";
        genericName = "Video Editor";
        exec = "${pkgs.davinci-resolve}/bin/davinci-resolve %U";
        terminal = false;
        categories = ["Application" "Video"];
      };
    };
  };
}
