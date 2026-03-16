{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
with lib; {
  xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"; # Set environment variables

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = mkForce false; # Incompatible with UWSM
    package = null; # Use the package from the NixOS module
    portalPackage = null; # Use the package from the NixOS module
    settings = {
      "$MONITOR-1" = mkDefault "";
      "$MONITOR-2" = mkDefault "";

      animations.enabled = true;

      decoration.rounding = 5;
      decoration.dim_inactive = true;
      decoration.dim_strength = 0.2;
      decoration.dim_around = 0.4;

      exec-once = [
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      dwindle.pseudotile = true;
      dwindle.preserve_split = true;

      general.gaps_in = 5;
      general.gaps_out = 10;
      general.border_size = 0;
      general.layout = "dwindle";

      input.kb_layout = elemAt 0 (strings.splitString "-" osConfig.console.keyMap);
      input.kb_variant = elemAt 1 (strings.splitString "-" osConfig.console.keyMap);
      input.follow_mouse = 1;
      input.sensitivity = 0;

      monitor = [", preferred, auto, 1"];

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

      # Keymaps
      bind = [
        # Applications shortcut
        "SUPER, Q, exec, ${config.home.sessionVariables.TERMINAL}" # Terminal
        # TODO: "SUPER, E, exec, " # File manager
        "SUPER, W, exec, xdg-open https://search.brave.com"

        # Launcher
        # TODO: "SUPER, S, exec, "
        "SUPER, I, exec, ${getExe pkgs.rofimoji}" # Emoji Picker

        # Navigation
        "SUPER, C, killactive"
        "SUPER, F, fullscreen"
        "SUPER_SHIFT, F, togglefloating"

        "SUPER, h, movefocus l"
        "SUPER, l, movefocus r"
        "SUPER, k, movefocus u"
        "SUPER, j, movefocus d"

        "SUPER, 1, workspace 1"
        "SUPER, 2, workspace 2"
        "SUPER, 3, workspace 3"
        "SUPER, 4, workspace 4"
        "SUPER, 5, workspace 5"
        "SUPER, 6, workspace 6"
        "SUPER, 7, workspace 7"
        "SUPER, 8, workspace 8"
        "SUPER, 9, workspace 9"
        "SUPER, 0, workspace 10"

        "SUPER_SHIFT, 1, movetoworkspace 1"
        "SUPER_SHIFT, 2, movetoworkspace 2"
        "SUPER_SHIFT, 3, movetoworkspace 3"
        "SUPER_SHIFT, 4, movetoworkspace 4"
        "SUPER_SHIFT, 5, movetoworkspace 5"
        "SUPER_SHIFT, 6, movetoworkspace 6"
        "SUPER_SHIFT, 7, movetoworkspace 7"
        "SUPER_SHIFT, 8, movetoworkspace 8"
        "SUPER_SHIFT, 9, movetoworkspace 9"
        "SUPER_SHIFT, 0, movetoworkspace 10"

        # Clipboard manager
        "SUPER, V, exec, cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"

        # Print region
        ",Print, exec, ${getExe pkgs.grim} -g \"$(${getExe slurp} -d)\" - | wl-copy"

        # Copy color
        "SUPER, P, exec, ${getExe pkgs.hyprpicker} | wl-copy"
      ];
      # Mouse Keymaps
      bindm = [
        "SUPER, mouse:272, movewindow" # Left-click
        "SUPER, mouse:273, resizewindow" # Right-click
      ];
    };
  };

  # Application Launcher
  programs.rofi = {
    enable = true;
    modes = ["drun" "emoji"];
  };

  # Clipboard
  services.cliphist = {
    enable = true;
    allowImages = true;
  };
  home.packages = with pkgs; [
    wl-clipboard
  ];

  # Notifications
  services.dunst = {
    enable = true;
    settings = {
      global.follow = "mouse";
    };
  };

  # Bar
  programs.waybar.settings = let
    layer = "top";
    position = "top";

    height = 25;
    spacing = 5;

    margin-top = 5;
    margin-x = 10;
    margin-right = margin-x;
    margin-left = margin-x;
  in {
    main = let
      monitor = config.wayland.windowManager.hyprland.settings."$MONITOR-1";
    in {
      inherit
        layer
        position
        height
        spacing
        margin-top
        margin-right
        margin-left
        ;

      output = [monitor];

      modules-left = [
        "hyprland/workspaces"
      ];

      "hyprland/workspaces" = {
        active-only = false;
        persistent-workspaces = {
          "${monitor}" = [1 2 3 4 5];
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

      modules-right = [
        "pulseaudio"
      ];

      "clock" = {
        format = "{:%d 󰥔 %R}";
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

      "pulseaudio" = {
        format = "{icon} {volume}%";
        format-muted = "";
        format-icons = {
          default = ["" ""];
        };
        onclick = "${lib.getExe pkgs.pwvucontrol}";
      };
    };
    secondary = let
      monitor = config.wayland.windowManager.hyprland.settings."$MONITOR-2";
    in {
      inherit
        layer
        position
        height
        spacing
        margin-top
        margin-right
        margin-left
        ;

      output = [monitor];

      modules-left = [
        "cpu"
        "memory"
        "disk"
      ];

      "cpu" = {
        format = " {usage}%";
      };

      "memory" = {
        format = " {percentage}%";
      };

      "disk" = {
        interval = 30;
        format = "󰨣 {specific_free:0.2f}";
        unit = "GB";
      };

      modules-center = [
        "hyprland/window"
      ];

      "hyprland/window" = {
        format = "{title}";
      };

      modules-right = [
        "hyprland/workspaces"
      ];

      "hyprland/workspaces" = {
        active-only = false;
        persistent-workspaces = {
          "${monitor}" = [6 7 8 9 10];
        };
        format = "{icon}";
        format-icons = {
          default = "";
          active = "";
        };
      };
    };
  };
}
