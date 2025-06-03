{
  self,
  pkgs,
  ...
}: {
  imports = [
    self.homeManagerModules.qutebrowser-profiles
  ];

  programs.qutebrowser.enable = true;
  programs.qutebrowser.settings = {
    auto_save.session = true;
    confirm_quit = ["downloads"];

    # Prevent fingerprinting
    content.canvas_reading = false;
    content.cookies.accept = "all";
    content.cookies.store = true;
    content.geolocation = false;
    content.webgl = false;
    content.webrtc_ip_handling_policy = "default-public-interface-only";
  };
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
    "art" = {};
    "personal" = {};
    "work" = {
      searchEngines = programmingSearchEngines;
    };
    "job" = {
      settings.confirm_quit = ["always"];
      settings = {
        content.webgl = true;
      };
      searchEngines = programmingSearchEngines;
    };
    "shopping" = {};
    "goverment" = {};
  };
}
