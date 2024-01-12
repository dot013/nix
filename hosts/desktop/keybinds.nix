{ pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/programs/hyprland.nix
  ];
  options.keybinds = { };
  config = {
    hyprland.binds.keyboard = [
      "$mod, Q, exec, ${pkgs.wezterm}/bin/wezterm"
      "$mod, C, killactive"
      "$mod, M, exit"
      "$mod, E, exec, ${pkgs.gnome.nautilus}/bin/nautilus"
      "$mod, V, togglefloating"
      "$mod, F, fullscreen"
      "$mod, Z, togglesplit"
      "$mod, S, exec, ${pkgs.rofi}/bin/rofi -show drun -show-icons"
      ",Print, exec, ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -d)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"

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
    hyprland.binds.mouse = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
  };
}
