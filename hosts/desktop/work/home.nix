{ config, pkgs, inputs, ... }:

{
  imports = [
    ../shared-home.nix
  ];

  theme.accent = "94e2d5";
  wm.wallpaper = ../../../static/guz-wallpaper-work.png;
  librewolf.profiles.work = {
    isDefault = true;
    id = 1;
    settings = {
      "webgl.disabled" = false;
      "browser.startup.homepage" = "https://github.com";
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.downloads" = false;
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "privacy.clearOnShutdown.cookies" = false;
    };
    extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
      darkreader
      canvasblocker
      smart-referer
      github-file-icons
      libredirect
    ];
  };

}
