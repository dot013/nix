{
  config,
  lib,
  pkgs,
  ...
}: {
  # Host specific overrides of the root home
  home-manager.users.guz = let
    cfg = config.home-manager.users.guz;
    hyprcfg = cfg.wayland.windowManager.hyprland.settings;
  in {
    wayland.windowManager.hyprland.settings = {
      "$MONITOR-1" = lib.mkForce "eDP-1";
    };

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
        "hyprland/window"
      ];

      "hyprland/workspaces" = {
        active-only = false;
        persistent-workspaces = {
          "${hyprcfg."$MONITOR-1"}" = [1 2 3 4 5];
        };
        format = "{icon}";
        format-icons = {
          default = "";
          active = "";
        };
      };

      "hyprland/window" = {
        format = "{title}";
      };

      modules-center = [
        "clock"
      ];

      "clock" = {
        format = "{:%d  %R}";
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

      modules-right = [
        "battery"
        "pulseaudio"
        "cpu"
        "memory"
        "disk"
      ];

      "battery" = {
        format-icons = ["" "" "" "" ""];
        format = "{icon} {capacity}%";
      };

      "pulseaudio" = {
        format = "{icon} {volume}%";
        format-muted = "";
        format-icons = {
          default = ["" ""];
        };
        onclick = "${lib.getExe pkgs.pwvucontrol}";
      };

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
    };

    services.xremap.config.modmap = [
      {
        name = "laptop remaps";
        remap = {
          # Capslock as esc and ctrl on hold
          "CapsLock" = {
            held = "leftctrl";
            alone = "esc";
            alone_timeout_millis = 150;
          };
          # "S" = {
          #   held = "leftalt";
          #   alone = "s";
          #   alone_timeout_millis = 150;
          # };
          # "D" = {
          #   held = "leftctrl";
          #   alone = "d";
          #   alone_timeout_millis = 150;
          # };
          # "F" = {
          #   held = "leftshift";
          #   alone = "f";
          #   alone_timeout_millis = 150;
          # };
          # "J" = {
          #   held = "rightshift";
          #   alone = "j";
          #   alone_timeout_millis = 150;
          # };
          # "K" = {
          #   held = "rightctrl";
          #   alone = "k";
          #   alone_timeout_millis = 150;
          # };
          # "L" = {
          #   held = "rightalt";
          #   alone = "l";
          #   alone_timeout_millis = 150;
          # };
        };
      }
    ];
  };
}
