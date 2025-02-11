{inputs, ...}: {
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = let
    browser = "app.zen-browser.zen.desktop";
    email = "org.mozilla.Thunderbird.desktop";
  in {
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;

    "message/rfc822" = email;
    "x-scheme-handler/mailto" = email;
    "text/calendar" = email;
    "text/x-vcard" = email;
  };

  services.flatpak.enable = true;
  services.flatpak.packages = [
    # Thunder Bird (Email Client)
    "org.mozilla.Thunderbird"
    # Brave (Work Browser)
    "com.brave.Browser"
    # Zen (Main Browser)
    "app.zen_browser.zen"
  ];
  services.flatpak.update.onActivation = true;
  services.flatpak.overrides = {
    global = {
      # Force wayland by default
      Context = {
        sockets = ["wayland" "!x11" "!fallback-x11"];
        filesystems = [
          # Access to user themes
          "$HOME/.icons"
          "$HOME/.themes"
        ];
      };
      Environment = {
        # Fix un-themed cursor in Wayland apps
        XCURSOR_PATH = "$HOME/.icons";
      };
    };
    "com.brave.Browser" = {Context.sockets = ["x11"];};
  };
}
