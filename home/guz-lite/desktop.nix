{
  config,
  lib,
  pkgs,
  self,
  ...
}: {
  imports = [self.homeManagerModules.eww];

  home.pointerCursor.enable = true;
  home.pointerCursor.name = "Vanilla-DMZ";
  home.pointerCursor.package = pkgs.vanilla-dmz;
  home.pointerCursor.gtk.enable = true;
  home.pointerCursor.x11.enable = true;
  home.pointerCursor.hyprcursor.enable = true;

  # Hyprland
  wayland.windowManager.hyprland.enable = true;
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

  # Status bar
  # programs.eww-custom.enable = true;
  # programs.eww-custom.widgets = let
  #   hyprland-workspaces = lib.getExe pkgs.hyprland-workspaces;
  #   hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
  #   jq = lib.getExe pkgs.jq;
  #   awk = lib.getExe' pkgs.gawk "awk";
  #   socat = lib.getExe pkgs.socat;
  #
  #   # Currently borked
  #   eww-active-workspace = pkgs.writeShellScriptBin "eww-active-workspace" ''
  #     ${hyprctl} monitors -j |
  #       ${jq} '.[] | select(.focused) | .activeWorkspace.id'
  #
  #     ${socat} -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - |
  #       stdbuf -o0 ${awk} -F '>>|,' -e '/^workspace>>/ {print $2}' -e '/^focusedmon>>/ {print $3}'
  #   '';
  #
  #   pulsemixer = lib.getExe pkgs.pulsemixer;
  #
  #   eww-volume = pkgs.writeShellScriptBin "eww-volume" ''
  #     sink="$(echo $(${pulsemixer} -l | grep 'Default' | grep 'sink-' | awk '{print $3}') | rev | cut -c 2- | rev)"
  #
  #     echo "$(${pulsemixer} --id "$sink" --get-volume | awk '{print $1}')"
  #   '';
  # in
  #   ''''
  #   + (with config.wayland.windowManager.hyprland.settings; ''
  #     (defvar MONITOR_W "${toString 2560}")
  #     (defvar GAPS_IN "${toString general.gaps_in}")
  #     (defvar GAPS_OUT "${toString general.gaps_out}")
  #   '')
  #   + (builtins.readFile ./eww/eww.yuck);
  # programs.eww-custom.addPath = [
  #   pkgs.coreutils
  # ];
  # programs.eww-custom.style =
  #   (with config.wayland.windowManager.hyprland.settings; ''
  #     $rounding: ${toString decoration.rounding}px;
  #     $gaps-in: ${toString general.gaps_in}px;
  #     $gaps-out: ${toString general.gaps_out}px;
  #   '')
  #   + (with config.stylix.fonts; ''
  #     $font-serif: '${serif.name}';
  #     $font-sans-serif: '${sansSerif.name}';
  #     $font-monospace: '${monospace.name}';
  #     $font-emoji: '${emoji.name}';
  #   '')
  #   + (with config.lib.stylix.colors.withHashtag; ''
  #     $base00: ${base00};
  #     $base01: ${base01};
  #     $base02: ${base02};
  #     $base03: ${base03};
  #     $base04: ${base04};
  #     $base05: ${base05};
  #     $base06: ${base06};
  #     $base07: ${base07};
  #     $base08: ${base08};
  #     $base09: ${base09};
  #     $base0A: ${base0A};
  #     $base0B: ${base0B};
  #     $base0C: ${base0C};
  #     $base0D: ${base0D};
  #     $base0E: ${base0E};
  #     $base0F: ${base0F};
  #   '')
  #   + (builtins.readFile ./eww/eww.scss);

  ## Temp status bar
  programs.waybar.enable = true;
  programs.waybar.style = builtins.readFile ./waybar.css;
  # programs.waybar.settings.single = with builtins; fromJSON (readFile ./wayland.json);
  programs.waybar.settings.single = {
    layer = "top";
    position = "top";
    height = 25;
    spacing = 5;

    margin-top = 5;
    margin-right = 10;
    margin-left = 10;

    modules-left = [
      "hyprland/workspaces"
    ];

    "hyprland/workspaces" = {
      active-only = false;
      persistent-workspaces = let
        MONITOR-1 = config.wayland.windowManager.hyprland.settings."$MONITOR-1";
        MONITOR-2 = config.wayland.windowManager.hyprland.settings."$MONITOR-2";
      in {
        "${MONITOR-1}" = [1 2 3 4 5];
        "${MONITOR-2}" = [6 7 8 9 10];
      };
      format = "{icon}";
      format-icons = {
        default = "";
        active = "";
      };
    };
    modules-center = [
      "clock"
    ];

    "clock" = {
      format = "{:%R}";
      format-alt = "{:%B %d, 12.0%y (%A)}";
      tooltip-format = "<tt><small>{calendar}</small></tt>";
      calendar = {
        mode = "year";
        mode-mon-col = 3;
        weeks-pos = "left";
        on-scroll = 1;
        format = with config.lib.stylix.colors.withHashtag; {
          months = "<span color='${base09}'><b>{}</b></span>";
          days = "<span color='${base05}'><b>{}</b></span>";
          weeks = "<span color='${base09}'><b>W{}</b></span>";
          weeksdays = "<span color='${base09}'><b>{}</b></span>";
          today = "<span color='${base07}'><b>{}</b></span>";
        };
      };
    };

    "hyprland/window" = {
      format = "{title}";
    };

    modules-right = [
      "pulseaudio"
      "cpu"
      "memory"
      "disk"
    ];

    "disk" = {
      interval = 30;
      format = "{specific_free:0.2f}";
      unit = "GB";
    };
  };
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
