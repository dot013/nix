{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.xremap.homeManagerModules.default
  ];

  services.xremap.enable = true;
  services.xremap.withHypr = true;
  services.xremap.config.modmap = [
    # {
    #   name = "main remaps";
    #   remap = {
    #     # Capslock as esc and ctrl on hold
    #     "CapsLock" = {
    #       held = "leftctrl";
    #       alone = "esc";
    #       alone_timeout_millis = 150;
    #     };
    #     # Esc to single- and double-quote
    #     "Esc" = "grave";
    #     # single-quotes as Capslock
    #     "Grave" = "CapsLock";
    #   };
    # }
  ];
  services.xremap.config.keymap = let
    TERMINAL = config.home.sessionVariables.TERMINAL;
    EXPLORER = config.home.sessionVariables.EXPLORER;
    rofi = lib.getExe config.programs.rofi.finalPackage;

    exec = c:
      ["hyprctl" "dispatch" "exec"]
      ++ (
        if builtins.isString c
        then [c]
        else c
      );

    MODE_DEFAULT = "default";
    move = d: ["hyprctl" "dispatch" "movefocus" d];
    close = _: ["hyprctl" "dispatch" "killactive"];
    switchWorkspace = w: ["hyprctl" "dispatch" "workspace" w];
    toggleFullscreen = _: ["hyprctl" "dispatch" "fullscreen"];
    toggleFloating = _: ["hyprctl" "dispatch" "togglefloating"];
    toggleSplit = _: ["hyprctl" "dispatch" "togglesplit"];

    MODE_ARREGEMENT = "arregement";
    moveTile = d: ["hyprctl" "dispatch" "movewindow" d];
    switchTileWorkspace = w: ["hyprctl" "dispatch" "movetoworkspace" w];

    MODE_RESIZING = "resizing";
    resize = d:
      [
        "hyprctl"
        "dispatch"
        "resizeactive"
      ]
      ++ {
        "l" = ["-10" "0"];
        "r" = ["10" "0"];
        "u" = ["0" "-10"];
        "d" = ["0" "10"];
      }
      .${d};

    movementBinds = {
      # Move between tiles
      "super-h" = {launch = move "l";};
      "super-l" = {launch = move "r";};
      "super-k" = {launch = move "u";};
      "super-j" = {launch = move "d";};
      # Move between workspaces
      "super-1" = {launch = switchWorkspace "1";};
      "super-2" = {launch = switchWorkspace "2";};
      "super-3" = {launch = switchWorkspace "3";};
      "super-4" = {launch = switchWorkspace "4";};
      "super-5" = {launch = switchWorkspace "5";};
      "super-6" = {launch = switchWorkspace "6";};
      "super-7" = {launch = switchWorkspace "7";};
      "super-8" = {launch = switchWorkspace "8";};
      "super-9" = {launch = switchWorkspace "9";};
      "super-0" = {launch = switchWorkspace "10";};
    };
  in [
    {
      name = "General Keybindings";
      remap = {
        # Terminal
        "super-q" = {launch = exec "${TERMINAL}";};
        # File explorer
        "super-e" = {launch = exec ["${TERMINAL}" "-e" "${EXPLORER}"];};
        # Web Browser
        "super-w" = {launch = exec ["xdg-open" "https://search.brave.com"];};
        # Launcher
        "super-s" = {
          launch = exec [
            (lib.getExe (pkgs.writeShellScriptBin "launcher" ''
              ${rofi} -show drun -theme ${config.xdg.configHome}/rofi/launcher.rasi
            ''))
          ];
        };
        # Toggle fullscreen
        "super-f" = {launch = toggleFullscreen "";};
        # Toggle floating
        "super-shift-f" = {launch = toggleFloating "";};
        # Close window
        "super-c" = {launch = close "";};
      };
      mode = MODE_DEFAULT;
    }
    {
      name = "Navigation Keybinds";
      remap =
        {
          # Switch modes
          "super-m" = {
            remap = {
              "a" = {set_mode = MODE_ARREGEMENT;};
              "r" = {set_mode = MODE_RESIZING;};
            };
          };

          # Kick move to workspace
          "super-shift-1" = {launch = switchTileWorkspace "1";};
          "super-shift-2" = {launch = switchTileWorkspace "2";};
          "super-shift-3" = {launch = switchTileWorkspace "3";};
          "super-shift-4" = {launch = switchTileWorkspace "4";};
          "super-shift-5" = {launch = switchTileWorkspace "5";};
          "super-shift-6" = {launch = switchTileWorkspace "6";};
          "super-shift-7" = {launch = switchTileWorkspace "7";};
          "super-shift-8" = {launch = switchTileWorkspace "8";};
          "super-shift-9" = {launch = switchTileWorkspace "9";};
          "super-shift-0" = {launch = switchTileWorkspace "10";};
        }
        // movementBinds;
      mode = MODE_DEFAULT;
    }
    {
      name = "Arregement Keybinds";
      remap =
        {
          # Exit mode mode
          "esc" = {set_mode = MODE_DEFAULT;};
          # Switch modes
          "super-m" = {
            remap = {
              "r" = {set_mode = MODE_RESIZING;};
            };
          };
          # Move tiles
          "h" = {launch = moveTile "l";};
          "l" = {launch = moveTile "r";};
          "k" = {launch = moveTile "u";};
          "j" = {launch = moveTile "d";};
          # Move tiles to workspace
          "1" = {launch = switchTileWorkspace "1";};
          "2" = {launch = switchTileWorkspace "2";};
          "3" = {launch = switchTileWorkspace "3";};
          "4" = {launch = switchTileWorkspace "4";};
          "5" = {launch = switchTileWorkspace "5";};
          "6" = {launch = switchTileWorkspace "6";};
          "7" = {launch = switchTileWorkspace "7";};
          "8" = {launch = switchTileWorkspace "8";};
          "9" = {launch = switchTileWorkspace "9";};
          "0" = {launch = switchTileWorkspace "10";};
          # Switch split
          "s" = {launch = toggleSplit "";};
          # Toggle fullscreen
          "f" = {launch = toggleFullscreen "";};
          # Toggle floating
          "shift-f" = {launch = toggleFloating "";};
          # Close window
          "c" = {launch = close "";};
        }
        // movementBinds;
      mode = MODE_ARREGEMENT;
    }
    {
      name = "Resizing Keybinds";
      remap =
        {
          # Exit mode mode
          "esc" = {set_mode = MODE_DEFAULT;};
          # Switch modes
          "super-m" = {
            remap = {
              "a" = {set_mode = MODE_ARREGEMENT;};
            };
          };
          # Move tiles
          "h" = {launch = resize "l";};
          "l" = {launch = resize "r";};
          "k" = {launch = resize "u";};
          "j" = {launch = resize "d";};
          # Switch split
          "s" = {launch = toggleSplit "";};
          # Toggle fullscreen
          "f" = {launch = toggleFullscreen "";};
          # Toggle floating
          "shift-f" = {launch = toggleFloating "";};
          # Close window
          "c" = {launch = close "";};
        }
        // movementBinds;
      mode = MODE_RESIZING;
    }
  ];

  wayland.windowManager.hyprland.settings.bind = let
    rofi = lib.getExe config.programs.rofi.finalPackage;
    grim = lib.getExe pkgs.grim;
    slurp = lib.getExe pkgs.slurp;
  in [
    "SUPER, V, exec, cliphist list | ${rofi} -dmenu | cliphist decode | wl-copy" # For some reason this doesn't work on xremap
    ",Print, exec, ${grim} -g \"$(${slurp} -d)\" - | wl-copy"
  ];
  wayland.windowManager.hyprland.settings.bindm = [
    # Left-click
    "$MOD, mouse:272, movewindow"
    # Right-click
    "$MOD, mouse:273, resizewindow"
  ];
}
