{
  inputs,
  pkgs,
  self,
  ...
}: {
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = let
    browser = "zen.desktop";
  in {
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
  };

  programs.zen-browser.enable = true;
}
