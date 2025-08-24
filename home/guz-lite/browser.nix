{
  config,
  lib,
  osConfig,
  pkgs,
  self,
  ...
}: {
  imports = [
    self.homeManagerModules.zen-browser
  ];

  xdg.mimeApps.defaultApplications = with lib;
    listToAttrs (map (name: {
        inherit name;
        value = config.programs.zen-browser.package.meta.desktopFileName;
      }) [
        "application/x-extension-shtml"
        "application/x-extension-xhtml"
        "application/x-extension-html"
        "application/x-extension-xht"
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

  programs.zen-browser = let
    locked = v: {
      Value = v;
      Status = "locked";
    };
    settings = {
      "beacon.enabled" = locked false;
      "browser.startup.page" = locked 3;
      "device.sensors.enabled" = locked false;
      "dom.battery.enabled" = locked false;
      "dom.event.clipboardevents.enabled" = locked false;
      "geo.enabled" = locked false;
      "media.peerconnection.enabled" = locked false;
      "privacy.clearHistory.cookiesAndStorage" = locked false;
      "privacy.clearHistory.siteSettings" = locked false;
      "privacy.firstparty.isolate" = locked true;
      "privacy.resistFingerprinting" = locked true;
      "privacy.trackingprotection.enabled" = locked true;
      "privacy.trackingprotection.socialtracking.enabled" = locked true;
      "webgl.disabled" = true;
      "zen.view.use-single-toolbar" = false;
    };
  in {
    enable = true;
    profiles."default" = {
      containersForce = true;
      containers = {
        Personal = {
          color = "purple";
          icon = "fingerprint";
          id = 1;
        };
        Work = {
          color = "blue";
          icon = "briefcase";
          id = 2;
        };
        Shopping = {
          color = "yellow";
          icon = "cart";
          id = 4;
        };
        Goverment = {
          color = "orange";
          icon = "dollar";
          id = 5;
        };
      };
      extensions.force = true;
      extensions.settings = {
        "tridactyl.vim@cmcaine.co.uk".settings = {
          userconfig = {
            configVersion = "2.0";
            nmaps = {
              "K" = "tabprev";
              "J" = "tabnext";
            };
            theme = "midnight";
            searchurls = with lib;
              mapAttrs' (n: v:
                nameValuePair
                (
                  if v?definedAliases
                  then elemAt v.definedAliases 0
                  else n
                )
                (replaceString "{searchTerms}" "" (elemAt v.urls 0).template))
              config.programs.zen-browser.profiles."default".search.engines;
          };
        };
        "uBlock0@raymondhill.net".settings = {
          selectedFilterLists = [
            "user-filters"
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-unbreak"
            "ublock-quick-fixes"
            "easylist"
            "easyprivacy"
            "urlhaus-1"
            "plowe-0"
          ];
          dynamicFilteringString = ''
            behind-the-scene * * noop
            behind-the-scene * inline-script noop
            behind-the-scene * 1p-script noop
            behind-the-scene * 3p-script noop
            behind-the-scene * 3p-frame noop
            behind-the-scene * image noop
            behind-the-scene * 3p noop
            * * 3p-script block
            * * 3p-frame block
            capytal.cc * * noop
            capytal.company * * noop
            guz.one * * noop
            keikos.work * * noop
            lored.dev * * noop
            home-manager-options.extranix.com extranix.com * noop
            home-manager-options.extranix.com home-manager-options.extranix.com * noop
          '';
        };
        "{ef87d84c-2127-493f-b952-5b4e744245bc}".settings = {
          baseUrl = "http://127.0.0.1:5600";
          consentRequired = true;
          consent = true;
          hostname = osConfig.networking.hostName;
          enabled = true;
          browserName = "zen";
        };
        "7esoorv3@alefvanoon.anonaddy.me".settings = with builtins; fromJSON (readFile ./libredirect.json);
      };
      search.default = "brave";
      search.force = true;
      search.engines = {
        brave = {
          name = "Brave";
          urls = [{template = "https://search.brave.com/search?q={searchTerms}";}];
        };
        nix-packages = {
          name = "Nix Packages";
          urls = [{template = "https://search.nixos.org/packages?query={searchTerms}";}];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["@pkg"];
        };
        nix-options = {
          name = "Nix Options";
          urls = [{template = "https://search.nixos.org/options?query={searchTerms}";}];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["@opt"];
        };
        nix-home-manager = {
          name = "Home Manager";
          urls = [{template = "https://home-manager-options.extranix.com/?query={searchTerms}";}];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["@hm"];
        };
        nix-noodle = {
          name = "Noodle";
          urls = [{template = "https://noogle.dev/q?term={searchTerms}";}];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["@lib"];
        };
      };
      settings = with builtins;
        mapAttrs (n: v:
          if isAttrs v
          then v.Value
          else v)
        settings;
      shortcuts = {
        "key_search" = {key = "";};
        "key_search2" = {key = "";};
        "zen-workspace-forward" = {
          key = "j";
          modifiers = {
            control = true;
          };
          action = "cmd_zenWorkspaceForward";
        };
        "zen-workspace-backward" = {
          key = "k";
          modifiers = {
            control = true;
          };
          action = "cmd_zenWorkspaceBackward";
        };
      };
      spacesForce = true;
      spaces = let
        containers = config.programs.zen-browser.profiles."default".containers;
      in {
        "Space" = {
          id = "c6de089c-410d-4206-961d-ab11f988d40a";
          position = 1000;
        };
        "Work" = {
          id = "cdd10fab-4fc5-494b-9041-325e5759195b";
          icon = "chrome://browser/skin/zen-icons/selectable/star-1.svg";
          container = containers."Work".id;
          position = 2000;
        };
        "Shopping" = {
          id = "78aabdad-8aae-4fe0-8ff0-2a0c6c4ccc24";
          icon = "chrome://browser/skin/zen-icons/selectable/basket.svg";
          container = containers."Shopping".id;
          position = 5000;
        };
        "Goverment" = {
          id = "7e83e835-caef-4b94-be0c-b6b3959d0830";
          icon = "chrome://browser/skin/zen-icons/selectable/folder.svg";
          container = containers."Goverment".id;
          position = 6000;
        };
      };
    };
    policies = {
      AutofillAdressEnabled = true;
      AutofillCreditCardEnabled = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      ExtensionSettings = {
        "@contain-facebook" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/facebook-container/latest.xpi";
          installation_mode = "force_installed";
        };
        "7esoorv3@alefvanoon.anonaddy.me" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/libredirect/latest.xpi";
          installation_mode = "force_installed";
        };
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };
        "addon@simplelogin" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/simplelogin/latest.xpi";
          installation_mode = "force_installed";
        };
        "deArrow@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/dearrow/latest.xpi";
          installation_mode = "force_installed";
        };
        "idcac-pub@guus.ninja" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/istilldontcareaboutcookies/latest.xpi";
          installation_mode = "force_installed";
        };
        "tridactyl.vim@cmcaine.co.uk" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/tridactyl-vim/latest.xpi";
          installation_mode = "force_installed";
        };
        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          installation_mode = "force_installed";
        };
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "{74145f27-f039-47ce-a470-a662b129930a}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
          installation_mode = "force_installed";
        };
        "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/violentmonkey/latest.xpi";
          installation_mode = "force_installed";
        };
        "{ef87d84c-2127-493f-b952-5b4e744245bc}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/aw-watcher-web/latest.xpi";
          installation_mode = "force_installed";
        };
      };
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      Preferences = with builtins;
        mapAttrs (
          n: v:
            if isAttrs v
            then v
            else {Value = v;}
        )
        settings;
      ShowHomeButton = false;
      WindowsSSO = false;
    };
  };

  programs.mpv.enable = true;
  programs.mpv.scripts = with pkgs.mpvScripts; [
    quality-menu
    sponsorblock
  ];
}
