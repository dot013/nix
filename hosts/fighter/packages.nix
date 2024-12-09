{
  config,
  pkgs,
  inputs,
  ...
} @ args: {
  imports = [
    inputs.dot013-environment.homeManagerModule
    inputs.rec-sh.homeManagerModules.rec-sh
    inputs.dot013-neovim.homeManagerModules.neovim
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
    "battleship" = {
      hostname = "${args.osConfig.battleship-secrets.lesser.devices.battleship}";
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
          multi-account-containers
          libredirect
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
  ];

  services.easyeffects.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
  home.packages = with pkgs; [
    pavucontrol
    libreoffice
    pinentry
    gnome.nautilus
    ferdium
    act
    showmethekey
    bluetuith
  ];
}
