{
  config,
  pkgs,
  ...
}: {
  imports = [
  ];

  programs.hyprland.enable = true;
  programs.hyprland.settings = let
    cliphist = "${pkgs.cliphist}/bin/cliphist";
    librewolf = "${pkgs.librewolf}/bin/librewolf";
    terminal = "${config.profiles.gterminal.emulator.bin}";
    mod = "SUPER";
    rofi = "${pkgs.rofi}/bin/rofi";
    grim = "${pkgs.grim}/bin/grim";
    slurp = "${pkgs.slurp}/bin/slurp";
    wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  in {
    bind = [
      "${mod}, C, killactive"
      "${mod}, M, exit"
      "${mod}, R, togglefloating"
      "${mod}, F, fullscreen"
      "${mod}, Z, togglesplit"
      "${mod}, Q, exec, ${terminal}"
      "${mod}, E, exec, ${terminal} -e lf"
      "${mod} + SHIFT, E, exec, ${librewolf}"
      "${mod}, S, exec, ${rofi} -show drun -show-icons"
      ",Print, exec, ${grim} -g \"$(${slurp} -d)\" - | ${wl-copy}"
      "${mod}, V, exec, ${cliphist} list | ${rofi} -dmenu | ${cliphist} decode | ${wl-copy}"

      "${mod}, 1, workspace, 1"
      "${mod}, 2, workspace, 2"
      "${mod}, 3, workspace, 3"
      "${mod}, 4, workspace, 4"
      "${mod}, 5, workspace, 5"
      "${mod} + SHIFT, 1, movetoworkspace, 1"
      "${mod} + SHIFT, 2, movetoworkspace, 2"
      "${mod} + SHIFT, 3, movetoworkspace, 3"
      "${mod} + SHIFT, 4, movetoworkspace, 4"
      "${mod} + SHIFT, 5, movetoworkspace, 5"

      "${mod}, 6, workspace, 6"
      "${mod}, 7, workspace, 7"
      "${mod}, 8, workspace, 8"
      "${mod}, 9, workspace, 9"
      "${mod}, 0, workspace, 10"
      "${mod} + SHIFT, 6, movetoworkspace, 6"
      "${mod} + SHIFT, 7, movetoworkspace, 7"
      "${mod} + SHIFT, 8, movetoworkspace, 8"
      "${mod} + SHIFT, 9, movetoworkspace, 9"
      "${mod} + SHIFT, 0, movetoworkspace, 10"

      "${mod}, H, movefocus, l"
      "${mod}, L, movefocus, r"
      "${mod}, K, movefocus, u"
      "${mod}, J, movefocus, d"
    ];
    bindm = [
      "${mod}, mouse:272, movewindow"
      "${mod}, mouse:273, resizewindow"
    ];
  };
}
