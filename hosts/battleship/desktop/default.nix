{
  config,
  pkgs,
  ...
}: let
  wallpaper = ../../../static/guz-wallpaper-default.png;
  desktop-boot = pkgs.writeShellScriptBin "desktop-boot" ''
    function eww() { ${config.programs.eww.package}/bin/eww "$@"; }
    function swww() { ${pkgs.swww}/bin/swww "$@"; }
    function swww-daemon() { ${pkgs.swww}/bin/swww-daemon "$@"; }

    if [[ "$(eww ping)" -ne "pong" ]]; then
      eww daemon &> /dev/null
    fi

    eww close-all
    eww open bar
    eww open bar-2
    eww reload

    (swww-daemon &> /dev/null) & swww img "${/. + wallpaper}"
  '';
  desktop-update = pkgs.writeShellScriptBin "desktop-update" ''
    function hyprctl() { ${config.wayland.windowManager.hyprland.package}/bin/hyprctl; }
    # hyprctl reload
  '';
in {
  imports = [
    ./keymaps.nix
    ./colors
    ./eww
  ];

  programs.hyprland.enable = true;
  programs.hyprland.settings = let
    monitor-1 = "HDMI-A-1";
    monitor-2 = "DVI-D-1";
  in {
    animations = {
      enabled = true;

      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };
    decoration = {
      rounding = 5;
      dim_inactive = true;
      dim_strength = 0.2;
      dim_around = 0.4;

      blur.enabled = false;
    };
    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };
    exec = [
      "${desktop-boot}/bin/desktop-boot"
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    ];
    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 0;
      "col.active_border" = "rgba(ffffff99) rgba(ffffff33) 90deg";
      "col.inactive_border" = "rgba(18181800)";
      layout = "dwindle";
    };
    gestures.workspace_swipe = false;
    input = {
      kb_layout = "br";
      kb_variant = "abnt2";
      follow_mouse = 1;
      sensitivity = 0;
    };
    master.new_is_master = true;
    monitor = [
      "${monitor-1},2560x1080,0x0,1"
      "${monitor-2},1920x1080,2560x0,1"
    ];
    windowrulev2 = [
      "float,class:^(org.inkscape.Inkscape)$"
      "tile,class:^(org.inkscape.Inkscape)$,title:(.*)(- Inkscape)$"
    ];
    workspace = [
      # Primary monitor
      "1,monitor:${monitor-1},default:true"
      "2,monitor:${monitor-1}"
      "3,monitor:${monitor-1}"
      "4,monitor:${monitor-1}"
      "5,monitor:${monitor-1}"
      # Second monitor
      "6,monitor:${monitor-2}"
      "7,monitor:${monitor-1}"
      "8,monitor:${monitor-1}"
      "9,monitor:${monitor-1}"
      "0,monitor:${monitor-1},default:true"
    ];
  };

  home.activation = {
    desktop-update = "${desktop-update}/bin/desktop-update";
  };
}
