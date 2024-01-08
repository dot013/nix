{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home-manager/theme.nix
    ../../modules/home-manager/config/terminal.nix
  ];

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {

    "$monitor1" = "HDMI-A-1";
    "$monitor2" = "DVI-D-1";

    monitor = [
      "$monitor1,2560x1080@60,0x0,1"
      "$monitor2,1920x1080@60,2560x0,1"
    ];

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
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    '';
  };

  services.flatpak.packages = [
    "nz.mega.MEGAsync"
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
  home.packages = with pkgs; [
    ## Programs
    obsidian
    firefox

    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    ## Fonts
    fira-code
  ];

  fonts.fontconfig.enable = true;


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/guz/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };
}

