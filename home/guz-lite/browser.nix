{
  self,
  pkgs,
  lib,
  ...
}: {
  imports = [
    self.homeManagerModules.qutebrowser-profiles
  ];

  programs.qutebrowser.enable = true;
  programs.qutebrowser.settings = with lib; {
    auto_save.session = true;
    confirm_quit = ["downloads"];

    tabs.position = "left";

    # Colors
    colors.tabs.pinned.even.bg = mkForce "#181818";
    colors.tabs.pinned.odd.bg = mkForce "#181818";

    colors.tabs.selected.even.bg = mkForce "#CDD6F4"; # Catppuccin's Text
    colors.tabs.selected.odd.bg = mkForce "#CDD6F4"; # Catppuccin's Text
    colors.tabs.selected.even.fg = mkForce "#111111";
    colors.tabs.selected.odd.fg = mkForce "#111111";

    colors.tabs.pinned.selected.even.bg = mkForce "#CDD6F4"; # Catppuccin's Text
    colors.tabs.pinned.selected.odd.bg = mkForce "#CDD6F4"; # Catppuccin's Text

    ## Darkmode
    colors.webpage.darkmode.enabled = true;
    colors.webpage.darkmode.algorithm = "lightness-cielab";
    colors.webpage.darkmode.policy.images = "never";

    # Prevent fingerprinting
    content.canvas_reading = false;
    content.cookies.accept = "all";
    content.cookies.store = true;
    content.geolocation = false;
    content.webgl = false;
    content.webrtc_ip_handling_policy = "default-public-interface-only";
  };
  programs.qutebrowser.extraConfig = ''
    config.set('colors.webpage.darkmode.enabled', False, 'file://*')
    config.set('colors.webpage.darkmode.enabled', False, 'http://*:*/*')

    config.set('colors.webpage.darkmode.enabled', False, 'capytal.company')
    config.set('colors.webpage.darkmode.enabled', False, '*.capytal.company')
    config.set('colors.webpage.darkmode.enabled', False, 'capytal.cc')
    config.set('colors.webpage.darkmode.enabled', False, '*.capytal.cc')
    config.set('colors.webpage.darkmode.enabled', False, 'lored.dev')
    config.set('colors.webpage.darkmode.enabled', False, '*.lored.dev')
    config.set('colors.webpage.darkmode.enabled', False, 'guz.one')
    config.set('colors.webpage.darkmode.enabled', False, '*.guz.one')
  '';
  programs.qutebrowser.searchEngines = {
    DEFAULT = "https://search.brave.com/search?q={}";
    # Nix
    pkg = "https://search.nixos.org/packages?query={}";
    opt = "https://search.nixos.org/options?query={}";
    lib = "https://noogle.dev/q?term={}";
    hm = "https://home-manager-options.extranix.com/?query={}";
    wiki = "https://nixos.wiki/index.php?search={}&go=Go";

    # Wikipedia
    w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
    wpt = "https://pt.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
  };
  programs.qutebrowser.greasemonkey = [
    # Youtube Adblocking
    (pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/afreakk/greasemonkeyscripts/refs/heads/master/youtube_adblock.js";
      hash = "sha256-AyD9VoLJbKPfqmDEwFIEBMl//EIV/FYnZ1+ona+VU9c=";
    })
    # Youtube Sponsorblock
    (pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/afreakk/greasemonkeyscripts/refs/heads/master/youtube_sponsorblock.js";
      hash = "sha256-nwNade1oHP+w5LGUPJSgAX1+nQZli4Rhe8FFUoF5mLE=";
    })
    # Reddit adblock
    (pkgs.fetchurl {
      url = "https://github.com/afreakk/greasemonkeyscripts/raw/refs/heads/master/reddit_adblock.js";
      hash = "sha256-KmCXL4GrZtwPLRyAvAxADpyjbdY5UFnS/XKZFKtg7tk=";
    })
    # Pinterest adblock
    (pkgs.writeText "pinterest_adblock.js" ''
      // ==UserScript==
      // @name         remove ads from pinterest
      // @version      1.0.0
      // @author       guz
      // @match        *://*.pinterest.com/*
      // ==/UserScript==

      const removeShit = () => {
          document.querySelectorAll('[data-grid-item]:has([title="Promoted by"])').forEach((e) => e.remove());
          document.querySelectorAll('[data-grid-item]:has([data-test-id="oneTapPromotedPin"])').forEach((e) => e.remove());
          document.querySelectorAll('[data-grid-item]:has([aria-label="Product Pin"])').forEach((e) => e.remove());
          // document.querySelectorAll('[data-grid-item]:has-text(ideas you might love)').forEach((e) => e.remove());
          // document.querySelectorAll('[data-grid-item]:has-text(Seaches to try)').forEach((e) => e.remove());
      };
      (trySetInterval = () => {
          window.setInterval(removeShit, 1000);
      })();
    '')
    # Privacy Redirector
    (pkgs.substitute {
      src = pkgs.fetchurl {
        url = "https://github.com/dybdeskarphet/privacy-redirector/raw/refs/heads/main/privacy-redirector.user.js";
        hash = "sha256-xj36+/3coiStIxftWCJUWHokSEmr+YRLOTktbmn5TkU=";
      };
      substitutions = [
        # ON-OFF (Redirection / Farside)
        "--replace"
        "pinterest = [true, true]"
        "pinterest = [false, false]"
        "--replace"
        "tumblr = [true, false]"
        "tumblr = [false, false]"
        "--replace"
        "wikipedia = [true, false]"
        "wikipedia = [false, false]"
        "--replace"
        "youtube = [true, false]"
        "youtube = [false, false]"
      ];
    })
  ];
  programs.qutebrowser.profiles = let
    programmingSearchEngines = {
      # Languages
      go = "https://pkg.go.dev/search?q={}";
    };
  in {
    "art" = {
      settings = {
        colors.tabs.selected.even.bg = "#CBA6F7"; # Catppuccin's Mauve
        colors.tabs.selected.odd.bg = "#CBA6F7"; # Catppuccin's Mauve
        colors.tabs.pinned.selected.even.bg = "#CBA6F7"; # Catppuccin's Mauve
        colors.tabs.pinned.selected.odd.bg = "#CBA6F7"; # Catppuccin's Mauve
      };
    };
    "personal" = {
      settings = {
        colors.tabs.selected.even.bg = "#F5E0DC"; # Catppuccin's Rosewater
        colors.tabs.selected.odd.bg = "#F5E0DC"; # Catppuccin's Rosewater
        colors.tabs.pinned.selected.even.bg = "#F5E0DC"; # Catppuccin's Rosewater
        colors.tabs.pinned.selected.odd.bg = "#F5E0DC"; # Catppuccin's Rosewater
      };
    };
    "work" = {
      settings = {
        colors.tabs.selected.even.bg = "#74C7EC"; # Catppuccin's Sapphire
        colors.tabs.selected.odd.bg = "#74C7EC"; # Catppuccin's Sapphire
        colors.tabs.pinned.selected.even.bg = "#74C7EC"; # Catppuccin's Sapphire
        colors.tabs.pinned.selected.odd.bg = "#74C7EC"; # Catppuccin's Sapphire
      };
      searchEngines = programmingSearchEngines;
    };
    "job" = {
      settings = {
        confirm_quit = ["always"];
        content.webgl = true;

        colors.tabs.selected.even.bg = "#A6E2A1"; #Catppuccin's Green
        colors.tabs.selected.odd.bg = "#A6E2A1"; #Catppuccin's Green
        colors.tabs.pinned.selected.even.bg = "#A6E2A1"; #Catppuccin's Green
        colors.tabs.pinned.selected.odd.bg = "#A6E2A1"; #Catppuccin's Green
      };
      searchEngines = programmingSearchEngines;
    };
    "shopping" = {
      settings = {
        colors.tabs.selected.even.bg = "#F9E2AF"; # Catppuccin's Yellow
        colors.tabs.selected.odd.bg = "#F9E2AF"; # Catppuccin's Yellow
        colors.tabs.pinned.selected.even.bg = "#F9E2AF"; # Catppuccin's Yellow
        colors.tabs.pinned.selected.odd.bg = "#F9E2AF"; # Catppuccin's Yellow
      };
    };
    "goverment" = {
      settings = {
        colors.tabs.selected.even.bg = "#A6ADC8"; # Catppuccin's Subtext 1
        colors.tabs.selected.odd.bg = "#A6ADC8"; # Catppuccin's Subtext 1
        colors.tabs.pinned.selected.even.bg = "#A6ADC8"; # Catppuccin's Subtext 1
        colors.tabs.pinned.selected.odd.bg = "#A6ADC8"; # Catppuccin's Subtext 1
      };
    };
  };
}
