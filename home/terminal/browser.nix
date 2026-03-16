{
  config,
  lib,
  pkgs,
  self,
  ...
}:
with lib; {
  imports = [
    self.homeManagerModules.qutebrowser-profiles
    ./scripts.nix
    ./profiles.nix
  ];

  programs.qutebrowser = {
    enable = true;

    keyBindings = {
      normal = {
        ",m" = "spawn umpv {url}";
        ",M" = "hint links spawn umpv {hint-url}";
        ";M" = "hint --rapid links spawn umpv {hint-url}";
        "tD" = "config-cycle -t -u {url} colors.webpage.darkmode.enabled false true ;; reload";
      };
    };

    settings = {
      auto_save.session = true;
      confirm_quit = ["downloads"];

      tabs.width = builtins.floor (1920 * 0.1);
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

    extraConfig = ''
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

      # Thanks to @hseg on GitHub (https://github.com/qutebrowser/qutebrowser/issues/6880#issuecomment-1815248845)
      config.bind('o', 'cmd-set-text -s :open -s')
      config.bind('go', 'cmd-set-text :open -s {url:pretty}')
      config.bind('O', 'cmd-set-text -s :open -s -t')
      config.bind('gO', 'cmd-set-text :open -s -t -r {url:pretty}')
      config.bind('xo', 'cmd-set-text -s :open -s -b')
      config.bind('xO', 'cmd-set-text :open -s -b -r {url:pretty}')
      config.bind('wo', 'cmd-set-text -s :open -s -w')
      config.bind('wO', 'cmd-set-text :open -s -w {url:pretty}')
      config.bind('pp', 'open -s -- {clipboard}')
      config.bind('pP', 'open -s -- {primary}')
      config.bind('Pp', 'open -s -t -- {clipboard}')
      config.bind('PP', 'open -s -t -- {primary}')
      config.bind('wp', 'open -s -w -- {clipboard}')
      config.bind('wP', 'open -s -w -- {primary}')
    '';

    searchEngines = {
      DEFAULT = "https://search.brave.com/search?q={}";
      # Nix
      pkg = "https://search.nixos.org/packages?query={}";
      opt = "https://search.nixos.org/options?query={}";
      lib = "https://noogle.dev/q?term={}";
      hm = "https://home-manager-options.extranix.com/?query={}";
      wiki = "https://wiki.nixos.org/w/index.php?search={}";

      # Wikipedia
      w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
      wpt = "https://pt.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
    };

    profiles = let
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
      "art".settings = setColor "#CBA6F7"; # Catppuccin's Mauve;
      "personal".settings = setColor "#F5E0DC"; # Catppuccin's Rosewater
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
      "shopping".settings = setColor "#F9E2AF"; # Catppuccin's Yellow
      "goverment".settings = setColor "#A6ADC8"; # Catppuccin's Subtext 1
      "academic".settings =
        {
          confirm_quit = ["always"];
          content.webgl = true;
        }
        // setColor "#19236F";
      "facebook".settings = setColor "#1877F2"; # Facebook's Blue
      "yt-music".settings =
        {
          tabs.width = 10;
        }
        // (setColor "#FF0000"); # Youtube's Red
    };

    greasemonkey = [
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
          "--replace"
          "instagram = [true, true]"
          "instagram = [false, false]"
        ];
      })
    ];
  };

  programs.mpv.enable = true;
  programs.mpv.scripts = with pkgs.mpvScripts; [
    quality-menu
    sponsorblock
  ];

  xdg.mimeApps.defaultApplications = listToAttrs (map (name: {
      inherit name;
      value = config.programs.qutebrowser.package.meta.desktopFileName;
    }) [
      "application/x-extension-shtml"
      "application/x-extension-xhtml"
      "application/x-extension-html"
      "application/x-extension-xhtm"
      "application/x-extension-htm"
      "x-scheme-handler/unknown"
      "x-scheme-handler/mailto"
      "x-scheme-handler/chrome"
      "x-scheme-handler/about"
      "x-scheme-handler/https"
      "x-scheme-handler/http"
      "application/xhtml+xml"
      "application/json"
      "text/plain"
      "text/html"
    ]);
}
