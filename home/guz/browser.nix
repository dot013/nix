{
  config,
  lib,
  osConfig,
  ...
}: {
  programs.zen-browser = {
    profiles."default" = {
      containers = {
        Job = {
          color = "green";
          icon = "briefcase";
          id = 3;
        };
      };
      # modsForce = true;
      # mods = let
      #   store = inputs.zen-theme-store;
      # in {
      #   "0c3d77bf-44fc-47a6-a183-39205dfa5f7e" = "${store}/themes/0c3d77bf-44fc-47a6-a183-39205dfa5f7e/theme.json";
      #   "c8d9e6e6-e702-4e15-8972-3596e57cf398" = pkgs.fetchurl {
      #     url = "https://raw.githubusercontent.com/zen-browser/theme-store/refs/heads/main/themes/c8d9e6e6-e702-4e15-8972-3596e57cf398/theme.json";
      #     hash = "sha256-v6VfUwdz01it0anDwwPcCSVufWCybue8CsPBd8X9KT0=";
      #   };
      # };
      spaces = let
        containers = config.programs.zen-browser.profiles."default".containers;
      in {
        "Work2" = {
          id = "1ea280f4-e428-4273-ace1-ad4f64a00cf5";
          icon = "chrome://browser/skin/zen-icons/selectable/star.svg";
          container = containers."Work".id;
          position = 3000;
        };
        "Work3" = {
          id = "2a5a1ca3-66df-4194-8ff9-63d0abb8eaae";
          icon = "chrome://browser/skin/zen-icons/selectable/sun.svg";
          container = containers."Work".id;
          position = 4000;
        };
        "Job" = lib.mkIf (osConfig.context.job) {
          id = "d7a663aa-3818-4ae7-b4b1-3d12a76d9c60";
          icon = "chrome://browser/skin/zen-icons/selectable/planet.svg";
          container = containers."Job".id;
          position = 4500;
        };
      };
    };
  };

  # The *state version* indicates which default
  # settings are in effect and will therefore help avoid breaking
  # program configurations. Switching to a higher state version
  # typically requires performing some manual steps, such as data
  # conversion or moving files.
  home.stateVersion = "24.11";
}
