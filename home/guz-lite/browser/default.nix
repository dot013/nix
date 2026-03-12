{
  config,
  self,
  pkgs,
  lib,
  ...
}:
with lib; {
  imports = [
    self.homeManagerModules.qutebrowser-profiles
    ./scripts.nix
    ./profiles.nix
  ];

  xdg.mimeApps.defaultApplications = with lib;
    listToAttrs (map (name: {
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

  programs.qutebrowser.enable = true;
  programs.qutebrowser.keyBindings = {
    normal = {
      ",m" = "spawn umpv {url}";
      ",M" = "hint links spawn umpv {hint-url}";
      ";M" = "hint --rapid links spawn umpv {hint-url}";
      "tD" = "config-cycle -t -u {url} colors.webpage.darkmode.enabled false true ;; reload";
    };
  };
  programs.qutebrowser.settings = {
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
  programs.qutebrowser.searchEngines = {
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

  programs.mpv.enable = true;
  programs.mpv.scripts = with pkgs.mpvScripts; [
    quality-menu
    sponsorblock
  ];
}
