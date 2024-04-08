{pkgs, ...}: {
  imports = [
    ../../modules/home-manager/programs/hyprland.nix
  ];
  options.keybinds = {};
  config = {
    hyprland.binds.keyboard = [
      "$mod, C, killactive"
      "$mod, M, exit"
      "$mod, V, togglefloating"
      "$mod, F, fullscreen"
      "$mod, Z, togglesplit"
      "$mod, Q, exec, ${pkgs.wezterm}/bin/wezterm"
      "$mod, E, exec, ${pkgs.wezterm}/bin/wezterm start lf"
      "$mod + SHIFT, E, exec, ${pkgs.librewolf}/bin/librewolf"
      "$mod, S, exec, ${pkgs.rofi}/bin/rofi -show drun -show-icons"
      ",Print, exec, ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -d)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"

      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod + SHIFT, 1, movetoworkspace, 1"
      "$mod + SHIFT, 2, movetoworkspace, 2"
      "$mod + SHIFT, 3, movetoworkspace, 3"
      "$mod + SHIFT, 4, movetoworkspace, 4"
      "$mod + SHIFT, 5, movetoworkspace, 5"

      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"
      "$mod + SHIFT, 6, movetoworkspace, 6"
      "$mod + SHIFT, 7, movetoworkspace, 7"
      "$mod + SHIFT, 8, movetoworkspace, 8"
      "$mod + SHIFT, 9, movetoworkspace, 9"
      "$mod + SHIFT, 0, movetoworkspace, 10"

      "$mod, H, movefocus, l"
      "$mod, L, movefocus, r"
      "$mod, K, movefocus, u"
      "$mod, J, movefocus, d"
    ];
    hyprland.binds.mouse = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
  };
}
