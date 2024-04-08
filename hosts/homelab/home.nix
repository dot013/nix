{...}: {
  imports = [
    ../../modules/home-manager
  ];

  profiles.gterminal.enable = true;
  programs.wezterm.enable = false;
}
