{
  config,
  pkgs,
  lib,
  ...
}: let
  wallpaper = ../../static/guz-wallpaper-default.png;
  desktop-boot = pkgs.writeShellScriptBin "desktop-boot" ''
    function eww() { ${config.programs.eww.package}/bin/eww "$@"; }
    function swww() { ${pkgs.swww}/bin/swww "$@"; }
    function swww-daemon() { ${pkgs.swww}/bin/swww-daemon "$@"; }

    if [[ "$(eww ping)" -ne "pong" ]]; then
      eww daemon &> /dev/null
    fi

    eww close-all
    eww open bar-full
    eww reload

    (swww-daemon &> /dev/null) & swww img "${/. + wallpaper}"
  '';
in
  with lib; {
    imports = [
      ../battleship/desktop
    ];

    programs.hyprland.settings = let
      monitor-1 = "eDP-1";
    in {
      exec = mkForce [
        "${desktop-boot}/bin/desktop-boot"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
        "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
      ];
      monitor = mkForce [
        "${monitor-1},1366x768,0x0,1"
      ];
      env = mkForce [];
      workspace = mkForce [
        "1,monitor:${monitor-1},default:true"
        "2,monitor:${monitor-1}"
        "3,monitor:${monitor-1}"
        "4,monitor:${monitor-1}"
        "5,monitor:${monitor-1}"
      ];
    };
  }
