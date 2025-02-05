{
  config,
  lib,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings.bind = [
    "$MOD, 1, workspace, 1"
    "$MOD, 2, workspace, 2"
    "$MOD, 3, workspace, 3"
    "$MOD, 4, workspace, 4"
    "$MOD, 5, workspace, 5"
    "$MOD + SHIFT, 1, movetoworkspace, 1"
    "$MOD + SHIFT, 2, movetoworkspace, 2"
    "$MOD + SHIFT, 3, movetoworkspace, 3"
    "$MOD + SHIFT, 4, movetoworkspace, 4"
    "$MOD + SHIFT, 5, movetoworkspace, 5"

    "$MOD, 6, workspace, 6"
    "$MOD, 7, workspace, 7"
    "$MOD, 8, workspace, 8"
    "$MOD, 9, workspace, 9"
    "$MOD, 0, workspace, 10"
    "$MOD + SHIFT, 6, movetoworkspace, 6"
    "$MOD + SHIFT, 7, movetoworkspace, 7"
    "$MOD + SHIFT, 8, movetoworkspace, 8"
    "$MOD + SHIFT, 9, movetoworkspace, 9"
    "$MOD + SHIFT, 0, movetoworkspace, 10"

    "$MOD, H, movefocus, l"
    "$MOD, L, movefocus, r"
    "$MOD, K, movefocus, u"
    "$MOD, J, movefocus, d"
  ];
  wayland.windowManager.hyprland.settings.bindm = [
    # Left-click
    "$MOD, mouse:272, movewindow"
    # Right-click
    "$MOD, mouse:273, resizewindow"
  ];
}
