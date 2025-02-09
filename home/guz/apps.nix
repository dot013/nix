{
  pkgs,
  self,
  ...
}: {
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

  home.packages =
    (with pkgs; [
      # Vesktop/Vencord (Discord client)
      vesktop
    ])
    ++ (with self.packages.${pkgs.system}.nixpak; [
      bitwarden-desktop
    ]);
}
