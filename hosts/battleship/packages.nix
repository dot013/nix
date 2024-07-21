{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.dot013-environment.homeManagerModule
    inputs.rec-sh.homeManagerModules.rec-sh
  ];

  programs.rec-sh.enable = true;

  dot013.environment.enable = true;
  dot013.environment.tmux.sessionizer.paths = ["~/.projects"];

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

  services.easyeffects.enable = true;

  home.sessionVariables = {
    STEAM_EXTRA_COMPACT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
  home.packages = with pkgs; [
    blender
    vesktop
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
    ferdium
    act
    protonup
    showmethekey
  ];
}
