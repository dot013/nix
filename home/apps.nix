{
  inputs,
  pkgs,
  self,
  ...
}: {
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = let
    browser = "zen.desktop";
    email = "thunderbird.desktop";
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

  programs.zen-browser.enable = true;

  programs.thunderbird.enable = true;
  programs.thunderbird.profiles = {};
}
