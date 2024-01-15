{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.hyprland;
in
{
  options.hyprland = with lib; with lib.types; {
    enable = mkEnableOption "";
    monitors = mkOption {
      default = [ ];
      # TODO: Fix types
      /* type = lib.types.listOf {
        name = lib.types.str;
        resolution = lib.types.str;
        hz = lib.types.nullOr lib.types.int;
        offset = lib.types.nullOr lib.types.str;
        scale = lib.types.nullOr lib.types.int;
      }; */
    };
    exec = mkOption {
      default = [ ];
      type = listOf str;
    };
    env = mkOption {
      default = { };
      type = attrsOf str;
    };
    windowRules = mkOption {
      default = { };
      description = "window = [ \"rule\" ]";
      # type = attrsOf listOf str;
    };
    input = {
      keyboard.layout = mkOption {
        default = "br";
        type = str;
      };
      keyboard.variant = mkOption {
        default = "abnt2";
        type = str;
      };
      mouse.follow = mkOption {
        default = true;
        type = bool;
      };
      mouse.sensitivity = mkOption {
        default = 0;
        type = number;
      };
    };
    general = {
      gaps_in = mkOption {
        default = 5;
        type = number;
      };
      gaps_out = mkOption {
        default = 10;
        type = number;
      };
      border.size = mkOption {
        default = 0;
        type = number;
      };
      border.color.active = mkOption {
        default = "rgba(ffffff99) rgba(ffffff33) 90deg";
        type = str;
      };
      border.color.inactive = mkOption {
        default = "rgba(18181800)";
        type = str;
      };
      layout = mkOption {
        default = "dwindle";
        type = str;
      };
    };
    decoration = {
      rouding = mkOption {
        default = 5;
        type = number;
      };
      dim.inactive = mkOption {
        default = true;
        type = bool;
      };
      dim.strength = mkOption {
        default = 0.2;
        type = number;
      };
      dim.around = mkOption {
        default = 0.4;
        type = number;
      };
    };
    animations = {
      enabled = mkOption {
        default = true;
        type = bool;
      };
    };
    workspaces = mkOption {
      default = [ ];
      /* type = {
        name = str;
        monitor = nullOr str;
        default = nullOr bool;
        extraRules = nullOr str;
      }; */
    };
    binds = {
      mod = mkOption {
        default = "SUPER";
        type = str;
      };
      keyboard = mkOption {
        default = [ ];
        type = listOf str;
      };
      mouse = mkOption {
        default = [ ];
        type = listOf str;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;

    wayland.windowManager.hyprland.xwayland.enable = true;
    wayland.windowManager.hyprland.systemd.enable = true;

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
        # Construct the "name,resolution@hz,offset,scale" strings
        monitor = (map
          (m:
            "${m.name},${m.resolution}@${
                toString (if m?hz then m.hz else 60)
              },${
                if m?offset then m.offset else "0x0"
              },${
                toString (if m?scale then m.scale else 1)
              }"
          )
          cfg.monitors
        );

        exec-once = cfg.exec;

        # "Hack" to transform attributes sets to lists (because I didn't know other way to do it)
        # Transform { "envName" = "value" } to [ "envName,value" ]
        env = builtins.attrValues
          (builtins.mapAttrs (n: v: "${n},${v}") (lib.attrsets.mergeAttrsList [
            {
              "XCURSOR_SIZE" = "24";
              "MOZ_ENABLE_WAYLAND" = "1";
            }
            cfg.env
          ]));


        windowrulev2 =
          let
            firefoxPipRules = [
              "float"
              "nofullscreenrequest"
              "size 480 270"
              "fakefullscreen"
              "nodim"
              "noblur"
            ];
          in
          builtins.concatLists
            (builtins.attrValues (builtins.mapAttrs
              (w: rs:
                (map (r: "${r},${w}") rs)
              )
              (lib.attrsets.mergeAttrsList [
                {
                  "title:^(Picture-in-Picture)$,class:^(firefox)$" = firefoxPipRules;
                  "title:^(Firefox)$,class:^(firefox)$" = firefoxPipRules;
                  # "title:^(Picture-in-Picture)$,class:^(librewolf)$" = firefoxPipRules;
                  # "title:^(LibreWolf)$,class:^(librewolf)$" = firefoxPipRules;
                  "class:^(xwaylandvideobridge)$" = [
                    "opacity 0.0 override 0.0 override"
                    "noanim"
                    "nofocus"
                    "noinitialfocus"
                  ];
                }
                cfg.windowRules
              ])
            ));

        input = {
          kb_layout = cfg.input.keyboard.layout;
          kb_variant = cfg.input.keyboard.variant;

          follow_mouse = if cfg.input.mouse.follow then "1" else "0";

          sensitivity = toString cfg.input.mouse.sensitivity;
        };

        general = {
          gaps_in = toString cfg.general.gaps_in;
          gaps_out = toString cfg.general.gaps_out;
          border_size = toString cfg.general.border.size;
          "col.active_border" = toString cfg.general.border.color.active;
          "col.inactive_border" = toString cfg.general.border.color.inactive;
          layout = cfg.general.layout;
        };

        decoration = {
          rounding = toString cfg.decoration.rouding;

          dim_inactive = if cfg.decoration.dim.inactive then "true" else "false";
          dim_strength = toString cfg.decoration.dim.strength;
          dim_around = toString cfg.decoration.dim.around;

          blur = {
            enabled = "false";
            size = "20";
          };
        };

        animations = {
          enabled = if cfg.animations.enabled then "yes" else "no";

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

        workspace =
          (map
            (w: "${w.name},${
                if w?monitor then "monitor:${w.monitor}," else ""
              }${
                if w?default && w.default then "default:true," else ""
              }${
                if w?extraRules then "${w.extraRules}" else ""
              }")
            cfg.workspaces
          );

        "$mod" = cfg.binds.mod;

        bind = cfg.binds.keyboard;
        bindm = cfg.binds.mouse;

      }
    ];
  };
}







