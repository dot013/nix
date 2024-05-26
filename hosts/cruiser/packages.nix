{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [];

  librewolf = {
    enable = true;
    profiles = {
      guz = {
        id = 0;
        settings = {
          "webgl.disabled" = false;
          "browser.startup.homepage" = "https://search.brave.com";
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.downloads" = false;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "privacy.clearOnShutdown.cookies" = false;
        };
        extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
          darkreader
          canvasblocker
          smart-referer
          libredirect
          tridactyl
        ];
      };
    };
  };

  programs.obsidian.enable = true;
  programs.obsidian.vaultCmd = true;
  programs.obsidian.vaultDir = "${config.home.homeDirectory}/.vault";

  programs.krita.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
  home.packages = with pkgs; [
    ## Programs
    vesktop
    pavucontrol
    pinentry
    gnome.nautilus

    ## Fonts
    fira-code
    (nerdfonts.override {fonts = ["FiraCode"];})
  ];
}
