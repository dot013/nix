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

  # Zen Browser (Main browser)
  programs.zen-browser.enable = true;

  # Brave (Work browser)
  programs.chromium.enable = true;
  programs.chromium.package = pkgs.brave;
  # programs.chromium.extensions = let
  #   libredirect = builtins.fetchurl {
  #     url = "https://github.com/libredirect/browser_extension/releases/download/v3.1.0/libredirect-3.1.0.crx";
  #     sha256 = "sha256:003q48gzyr282yk1l267myx4ba8dfb656lpxspx2gjhqmfdz9g8b";
  #   };
  # in [
  programs.chromium.extensions = [
    {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # Dark Reader
    {id = "oldceeleldhonbafppcapldpdifcinji";} # Language Tool
    # {
    #   id = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"; # TODO: Find correct id
    #   version = "3.1.0";
    #   crxPath = libredirect;
    # } # Libredirect
    {id = "edibdbjcniadpccecjdfdjjppcpchdlm";} # I still don't care about cookies
    {id = "dphilobhebphkdjbpfohgikllaljmgbn";} # SimpleLogin
    {id = "cbghhgpcnddeihccjmnadmkaejncjndb";} # Vencord
  ];

  # Thunderbird (Email client)
  programs.thunderbird.enable = true;
  programs.thunderbird.profiles = {};
}
