{config, ...}: {
  programs.qutebrowser.profiles = let
    programmingSearchEngines = {
      # Languages
      go = "https://pkg.go.dev/search?q={}";
    };
    setColor = c: {
      colors.tabs.selected.even.bg = c;
      colors.tabs.selected.odd.bg = c;
      colors.tabs.pinned.selected.even.bg = c;
      colors.tabs.pinned.selected.odd.bg = c;
    };
  in {
    "art" = {
      settings = setColor "#CBA6F7"; # Catppuccin's Mauve;
    };
    "personal" = {
      settings = setColor "#F5E0DC"; # Catppuccin's Rosewater
    };
    "work" = {
      settings = setColor "#74C7EC"; # Catppuccin's Sapphire
      searchEngines = programmingSearchEngines;
    };
    "job" = {
      settings =
        (config.programs.qutebrowser.profiles."work".settings)
        // {
          confirm_quit = ["always"];
          content.webgl = true;
        }
        // (setColor "#A6E2A1"); # Catppuccin's Green
      searchEngines = programmingSearchEngines;
    };
    "shopping" = {
      settings = setColor "#F9E2AF"; # Catppuccin's Yellow
    };
    "goverment" = {
      settings = setColor "#A6ADC8"; # Catppuccin's Subtext 1
    };
    "academic" = {
      settings =
        {
          confirm_quit = ["always"];
          content.webgl = true;
        }
        // setColor "#19236F";
    };
    "facebook" = {
      settings = setColor "#1877F2"; # Facebook's Blue
    };
    "yt-music" = {
      settings =
        {
          tabs.width = 10;
        }
        // (setColor "#FF0000"); # Youtube's Red
    };
  };
}
