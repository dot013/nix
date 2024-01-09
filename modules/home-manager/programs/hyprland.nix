{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.hyprland;
in
{
  options.hyprland = {
    enable = lib.mkEnableOption "";
    monitors = lib.mkOption {
      default = [ ];
      type = {
        name = lib.types.str;
        resolution = lib.types.str;
        hz = lib.types.nullOr lib.types.int;
        offset = lib.types.nullOr lib.types.str;
        scale = lib.types.nullOr lib.types.int;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.enable = true;

    # wayland.windowManager.hyprland.settings = { };

    wayland.windowManager.hyprland.settings = lib.mkMerge [
      # Sets monitor variables ("$name" = "id") so it can be used in rules later
      (builtins.listToAttrs (map
        (m: {
          name = "\$${m.name}";
          value = "${m.id}";
        })
        cfg.monitors)
      )
      {
        monitor = (map
          (m:
            "${
              m.name
            },${
              m.resolution
            }@${
              toString (if m?hz then m.hz else 60)
            },${
              if m?offset then m.offset else "0x0"
            },${
              toString (if m?scale then m.scale else 1)
            }")
          cfg.monitors
        );

        /*[
          "$monitor1,2560x1080@60,0x0,1"
          "$monitor2,1920x1080@60,2560x0,1"
            ];*/

        env = [
          "XCURSOR_SIZE,24"
          "MOZ_ENABLE_WAYLAND,1"
        ];

        windowrulev2 = [
          "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
          "noanim,class:^(xwaylandvideobridge)$"
          "nofocus,class:^(xwaylandvideobridge)$"
          "noinitialfocus,class:^(xwaylandvideobridge)$"
        ];

        input = {
          kb_layout = "br";
          kb_variant = "abnt2";

          follow_mouse = "1";

          sensitivity = "0";
        };

        general = {
          gaps_in = "5";
          gaps_out = "10";
          border_size = "0";
          "col.active_border" = "rgba(ffffff99) rgba(ffffff33) 90deg";
          "col.inactive_border" = "rgba(18181800)";
          layout = "dwindle";
        };

        decoration = {
          rounding = "5";

          dim_inactive = "true";
          dim_strength = "0.2";
          dim_around = "0.4";

          blur = {
            enabled = "false";
            size = "20";
          };
        };

        animations = {
          enabled = "yes";

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

        dwindle = {
          pseudotile = "yes";
          preserve_split = "yes";
        };

        master = {
          new_is_master = "true";
        };

        gestures = {
          workspace_swipe = "off";
        };

        "$mod" = "SUPER";

        workspace = [
          "1,monitor:$monitor1,default:true"
          "2,monitor:$monitor1"
          "3,monitor:$monitor1"

          "4,monitor:$monitor2,default:true"
          "5,monitor:$monitor2"
          "6,monitor:$monitor2"
        ];

        bind = [
          "$mod, Q, exec, ${pkgs.wezterm}/bin/wezterm"
          "$mod, C, killactive"
          "$mod, M, exit"
          "$mod, E, exec, ${pkgs.gnome.nautilus}/bin/nautilus"
          "$mod, V, togglefloating"
          "$mod, F, fullscreen"
          "$mod, Z, togglesplit"
          "$mod, S, exec, ${pkgs.rofi}/bin/rofi -show drun -show-icons"

          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod + SHIFT, 1, movetoworkspace, 1"
          "$mod + SHIFT, 2, movetoworkspace, 2"
          "$mod + SHIFT, 3, movetoworkspace, 3"

          "$mod, 8, workspace, 4"
          "$mod, 9, workspace, 5"
          "$mod, 0, workspace, 6"
          "$mod + SHIFT, 8, movetoworkspace, 4"
          "$mod + SHIFT, 9, movetoworkspace, 5"
          "$mod + SHIFT, 0, movetoworkspace, 6"

          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
        ];
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

      }
    ];
  };
}

