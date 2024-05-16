{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [];

  programs.brave.enable = true;
  programs.brave.extensions = [
    {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";}
    {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";}
  ];

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

  home.file."${config.home.homeDirectory}".text = ''
    prefix = $${HOME}/.npm-packages
  '';
  programs.zsh.initExtra = ''
    export PATH=~/.npm-packages/bin:$PATH
  '';

  programs.krita.enable = true;

  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];
  xdg.portal.config = {
    common.default = ["gtk"];
  };
  xdg.portal.xdgOpenUsePortal = true;
  services.flatpak.packages = [
    "nz.mega.MEGAsync"
    "com.bitwarden.desktop"
    "org.mozilla.Thunderbird"
    "net.blockbench.Blockbench"
    "de.shorsh.discord-screenaudio"
    "md.obsidian.Obsidian"
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
  home.packages = with pkgs; [
    ## Programs
    webcord-vencord
    gimp
    pureref
    gamemode
    lutris
    pavucontrol
    libreoffice
    pinentry
    gnome.nautilus
    inkscape
    latexrun
    zathura
  ];
}
