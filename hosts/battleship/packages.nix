{
  config,
  pkgs,
  inputs,
  ...
} @ args: {
  imports = [
    inputs.dot013-environment.homeManagerModule
    inputs.rec-sh.homeManagerModules.rec-sh
  ];

  programs.rec-sh.enable = true;

  dot013.environment.enable = true;
  dot013.environment.tmux.sessionizer.paths = ["~/.projects"];
  dot013.environment.ssh.devices = {
    "spacestation" = {
      hostname = "${args.osConfig.battleship-secrets.lesser.devices.spacestation}";
    };
    "figther" = {
      hostname = "${args.osConfig.battleship-secrets.lesser.devices.figther}";
    };
  };

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
          canvasblocker
          clearurls
          darkreader
          facebook-container
          libredirect
          multi-account-containers
          simplelogin
          smart-referer
          sponsorblock
          tridactyl
          ublock-origin
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
    "me.proton.Mail"
    "org.beeref.BeeRef"
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
    gamemode
    lutris
    pavucontrol
    libreoffice
    lmms
    pinentry
    gnome.nautilus
    inkscape
    latexrun
    zathura
    ferdium
    act
    protonup
    showmethekey
    bluetuith
  ];
}
