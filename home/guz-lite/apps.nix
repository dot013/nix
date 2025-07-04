{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.rec-sh.homeManagerModules.rec-sh
    ./browser.nix
  ];

  programs.rec-sh.enable = true;

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = let
    browser = "qutebrowser.desktop";
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
    # Brave (Job Browser)
    "com.brave.Browser"
  ];
  services.flatpak.update.onActivation = true;
  services.flatpak.overrides = {
    global = {
      # Force wayland by default
      Context = {
        sockets = ["wayland" "!x11" "!fallback-x11"];
        filesystems = [
          # Access to user themes
          "$HOME/.icons:ro"
          "$HOME/.themes:ro"
          "$HOME/.local/share/fonts:ro"
        ];
      };
      Environment = {
        # Fix un-themed cursor in Wayland apps
        XCURSOR_PATH = "$HOME/.icons";
      };
    };
    "com.brave.Browser" = {Context.sockets = ["x11"];};
  };

  home.packages = with pkgs; [
    nautilus
  ];
}
