{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.eww.enable = true;
  programs.eww.enableZshIntegration = true;

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
