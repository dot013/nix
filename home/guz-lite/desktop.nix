{
  config,
  lib,
  pkgs,
  ...
}: {
  home.pointerCursor.enable = true;
  home.pointerCursor.name = "Vanilla-DMZ";
  home.pointerCursor.package = pkgs.vanilla-dmz;
  home.pointerCursor.gtk.enable = true;
  home.pointerCursor.x11.enable = true;
  home.pointerCursor.hyprcursor.enable = true;

  # Hyprland
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.systemd.enable = false;
  wayland.windowManager.hyprland.xwayland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$MOD" = "SUPER";
    "$MONITOR-1" = lib.mkDefault "";
    "$MONITOR-2" = lib.mkDefault "";

    animations.enabled = true;

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

    exec-once = [
      "systemctl --user enable --now hyprpaper.service"
      "systemctl --user enable --now hypridle.service"
      "systemctl --user restart --now activitywatch-watcher-awatcher.service"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 0;
      layout = "dwindle";
    };

    input = {
      kb_layout = "br";
      kb_variant = "abnt2";
      follow_mouse = 1;
      sensitivity = 0;
    };

    monitor = [
      ", preferred, auto, 1"
    ];

    windowrulev2 = [
      # Inkscape pop-ups
      "float,class:^(org.inkscape.Inkscape)$"
      "tile,class:^(org.inkscape.Inkscape)$,title:(.*)(- Inkscape)$"

      # Blender pop-ups
      "float,class:^(blender)$,title:^(?!.*\ \-\ Blender).*$)"
    ];

    workspace = [
      # Primary monitor
      "1,monitor:$MONITOR-1,default:true"
      "2,monitor:$MONITOR-1"
      "3,monitor:$MONITOR-1"
      "4,monitor:$MONITOR-1"
      "5,monitor:$MONITOR-1"
      # Second monitor
      "6,monitor:$MONITOR-2"
      "7,monitor:$MONITOR-2"
      "8,monitor:$MONITOR-2"
      "9,monitor:$MONITOR-2"
      "10,monitor:$MONITOR-2,default:true"
    ];
  };

  ## Idle lock screen
  programs.hyprlock.enable = true;

  services.hypridle.enable = true;
  services.hypridle.settings = let
    hyprlock = lib.getExe config.programs.hyprlock.package;

    brightnessctl = lib.getExe pkgs.brightnessctl;
    hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
    loginctl = lib.getExe' pkgs.systemd "loginctl";
  in {
    general = {
      lock_cmd = "pidof ${hyprlock} || ${hyprlock}";
      before_sleep_cmd = "${loginctl} unlock-session";
      after_sleep_cmd = "${hyprctl} dispatch dpms on";
    };
    listener = {
      timeout = 10;
      on-timeout = "${brightnessctl} -sd rgb:kbd_backlight set 0 && ${hyprlock}";
      on-resume = "${brightnessctl} -rd rgb:kbd_backlight";
    };
  };

  ## Wallpaper
  services.hyprpaper.enable = true;

  ## File picker and other portals not implemented by XDPH
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];
  xdg.portal.config.common.default = ["gtk"];
  xdg.portal.xdgOpenUsePortal = true;

  ## Temp status bar
  programs.waybar.enable = true;
  programs.waybar.style = builtins.readFile ./waybar.css;
  programs.waybar.systemd.enable = true;

  # Notifications
  services.dunst.enable = true;
  services.dunst.settings = {
    global = {
      follow = "mouse";
    };
  };

  # Application Launcher
  programs.rofi.enable = true;

  # Clipboard
  services.cliphist.enable = true;
  services.cliphist.allowImages = true;
  home.packages = with pkgs; [
    wl-clipboard
  ];
}
