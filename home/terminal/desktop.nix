{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  # Activity Watch
  services.activitywatch.enable = true;
  services.activitywatch.package = pkgs.aw-server-rust;
  services.activitywatch.watchers = {
    "awatcher".package = pkgs.awatcher;
  };

  # GNOME
  programs.gnome-shell.enable = true;
  programs.gnome-shell.extensions = with pkgs.gnomeExtensions; [
    {package = activitywatch-status;}
    {package = arcmenu;}
    {package = blur-my-shell;}
    {package = focused-window-d-bus;}
    {package = forge;}
    {package = gsconnect;}
    {package = soft-brightness-plus;}
    {package = static-workspace-background;}
  ];

  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      accent-color = "slate";
    };
    "org/gnome/desktop/peripherals/tablets/256c:006d" = {
      keep-aspect = true;
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>C"];
      minimize = [];
      move-to-workspace-1 = ["<Shift><Super>1"];
      move-to-workspace-2 = ["<Shift><Super>2"];
      move-to-workspace-3 = ["<Shift><Super>3"];
      move-to-workspace-4 = ["<Shift><Super>4"];
      move-to-workspace-5 = ["<Shift><Super>5"];
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
      switch-to-workspace-5 = ["<Super>5"];
      toggle-quick-settings = [];
    };
    "org/gnome/desktop/wm/preferences" = {
      focus-mode = "mouse";
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = map (e:
        if e.package?extensionUuid
        then e.package.extensionUuid
        else e.id)
      config.programs.gnome-shell.extensions;
    };
    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };
    "org/gnome/shell/extensions/arcmenu" = {
      menu-button-appearance = "None";
      runner-hotkey = ["<Super>S"];
      runner-position = "Centered";
      runner-show-frequent-apps = true;
      show-activities-button = true;
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
    };
    "org/gnome/shell/extensions/forge" = {
      dnd-center-layout = "stacked";
      focus-on-hover-enabled = true;
      tabbed-tiling-mode-enabled = false;
      move-pointer-focus-enabled = true;
      window-toggle-float = ["<Shift><Super>F"];
      window-toggle-always-float = [];
    };
    "org/gnome/shell/keybindings" =
      # Remove keybindings for things such as Calendar, File Explorer, etc
      (genAttrs (map
        (n: "switch-to-application-${toString n}")
        (range 1 9))
      (n: []))
      // (genAttrs (map
        (n: "open-new-window-application-${toString n}")
        (range 1 9))
      (n: []));
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      num-workspaces = 5;
      workspace-only-on-primary = true;
    };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-to = 6.0;
      night-light-schedule-from = 21.0;
      night-light-temperature = 2700;
    };
    "org/gnome/settings-daemon/plugins/house-keeping" = {
      donation-reminder-enabled = false; # Sorry :(
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = [];
    };
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
    };
  };

  home.packages = with pkgs; [
    gnome-tweaks
  ];

  qt.enable = true;
  qt.style.name = "adwaita-dark";

  # Fonts
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts = with config.stylix.fonts; {
    sansSerif = [sansSerif.name];
    serif = [serif.name];
    monospace = [monospace.name];
    emoji = [emoji.name];
  };
  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font";
    };
  };
}
