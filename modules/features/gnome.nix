{
  nixos = {
    self,
    lib,
    ...
  }:
    with lib; {
      # GNOME (Desktop Manager)
      services.desktopManager.gnome = {
        enable = true;
      };

      # GDM (Display Manager)
      services.displayManager.gdm = {
        enable = mkDefault true;
      };

      # Pipewire
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # Policy Kit
      security.polkit.enable = true;

      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    };
  homeManager = {
    config,
    lib,
    pkgs,
    pkgs-unstable,
    ...
  }:
    with lib; {
      # GNOME
      programs.gnome-shell.enable = true;
      programs.gnome-shell.extensions = with pkgs-unstable.gnomeExtensions; [
        {package = blur-my-shell;}
        {package = focused-window-d-bus;}
        {package = gsconnect;}
        {package = rounded-window-corners-reborn;}
        {package = soft-brightness-plus;}
        {package = static-workspace-background;}
        {package = unite;}
      ];

      dconf.enable = true;
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          accent-color = "slate";
        };
        "org/gnome/desktop/media-handling" = {
          automount = false;
          automount-open = false;
        };
        "org/gnome/desktop/peripherals/tablets/256c:006d" = {
          keep-aspect = true;
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
        "org/gnome/shell/extensions/blur-my-shell/panel" = {
          blur = false;
        };
        "org/gnome/shell/extensions/unite" = {
          extend-left-box = false;
          grayscale-tray-icons = true;
          hide-activities-button = "never";
          hide-window-titlebars = "always";
          notifications-position = "right";
          reduce-panel-spacing = false;
          restrict-to-primary-screen = false;
          show-appmenu-button = false;
          show-desktop-name = false;
          show-legacy-tray = true;
          show-window-title = "never";
          show-window-buttons = "never";
          use-activities-text = false;
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

      home.packages = with pkgs; [nextcloud-client xprop];

      xdg.configFile."gtk-3.0/gtk.css".force = true;
      xdg.configFile."gtk-4.0/gtk.css".force = true;
    };
}
