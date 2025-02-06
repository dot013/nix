{pkgs, ...}: {
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

  # Work browser
  programs.chromium.enable = true;
  programs.chromium.package = pkgs.brave;
  programs.chromium.extensions = [
    {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # Dark Reader
    {id = "oldceeleldhonbafppcapldpdifcinji";} # Language Tool
    {id = "edibdbjcniadpccecjdfdjjppcpchdlm";} # I still don't care about cookies
    {id = "dphilobhebphkdjbpfohgikllaljmgbn";} # SimpleLogin
    {id = "cbghhgpcnddeihccjmnadmkaejncjndb";} # Vencord
  ];

  programs.thunderbird.enable = true;
  programs.thunderbird.profiles = {};
}
