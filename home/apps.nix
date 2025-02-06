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
  programs.chromium.extensions = [
    {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # Dark Reader
    {id = "oldceeleldhonbafppcapldpdifcinji";} # Language Tool
    {id = "edibdbjcniadpccecjdfdjjppcpchdlm";} # I still don't care about cookies
    {id = "dphilobhebphkdjbpfohgikllaljmgbn";} # SimpleLogin
    {id = "cbghhgpcnddeihccjmnadmkaejncjndb";} # Vencord
  ];

  # Thunderbird (Email client)
  programs.thunderbird.enable = true;
  programs.thunderbird.profiles = {};

  # Freetube (YouTube client)
  programs.freetube.enable = true;
  programs.freetube.settings = {
    # General

    ## Check for Updates
    checkForUpdates = false;

    ## Fallback to Non-Preferred Backend on Failure
    backendFallback = true;
    backendPreference = "invidious";

    ## Load comments and additional pages
    generalAutoLoadMorePaginatedItemsEnabled = true;

    ## Default Landing Page
    landingPage = "subscriptions";

    # Theme
    baseTheme = "black";
    mainColor = "CatppuccinFrappeRed";
    secColor = "CatppuccinFrappeBlue";

    hideHeaderLogo = true;
    hideLabelsSideBar = true;

    # Player
    proxyVideos = true;
    playNextVide = false;
    autoplayPlaylists = true;
    autoplayVideos = true;

    defaultViewingMode = "theatre";
    defaultQuality = 1080;

    # Subscription
    fetchSubscriptionsAutomatically = true;
    useRssFeeds = true;

    # Distraction Free
    hideTrendingVideos = true;
    hidePopularVideos = true;

    # Privacy
    rememberHistory = true;
    rememberSearchHistory = true;
    saveWatchedProgress = true;
    saveVideoHistoryWithLastViewedPlayliist = true;

    # Sponsor block
    useSponsorBlock = true;
    sponsorBlockFiller = {
      color = "CatppuccinFrappeMauve";
      skip = "showInSeekBar";
    };
    sponsorBlockInteraction = {
      color = "CatppuccinFrappePink";
      skip = "showInSeekBar";
    };
    sponsorBlockIntro = {
      color = "CatppuccinFrappeSky";
      skip = "showInSeekBar";
    };
    sponsorBlockMusicOffTopic = {
      color = "CatppuccinFrappePeache";
      skip = "showInSeekBar";
    };
    sponsorBlockOutro = {
      color = "CatppuccinFrappeBlue";
      skip = "showInSeekBar";
    };
    sponsorBlockRecap = {
      color = "CatppuccinFrappeLavender";
      skip = "showInSeekBar";
    };
    sponsorBlockSelfPromo = {
      color = "CatppuccinFrappeYellow";
      skip = "showInSeekBar";
    };
    sponsorBlockSponsor = {
      color = "CatppuccinFrappeGreen";
      skip = "autoSkip";
    };

    useDeArrowTitles = true;
    useDeArrowThumbnails = true;
  };
}
