{lib, ...}: {
  # Host specific overrides of the root home
  home-manager.users.guz = {
    wayland.windowManager.hyprland.settings = {
      "$MONITOR-1" = lib.mkForce "eDP-1";
    };

    programs.waybar.settings.single = {
      modules-right = [
        "battery"
      ];

      "battery" = {
        format-icons = ["" "" "" "" ""];
        format = "{icon} {capacity}%";
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
