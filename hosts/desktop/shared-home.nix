{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home-manager/theme.nix
    ../../modules/home-manager/programs/librewolf
    ../../modules/home-manager/packages/nixx.nix
    ../../modules/home-manager/packages/nixi.nix
    ./terminal.nix
    ./wm.nix
    ./keybinds.nix
    ./.desktop
  ];

  programs.bash = {
    enable = true;
    initExtra = ''
      export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"

      export GPG_TTY=$(tty)
    '';
  };

  services.gnome-keyring.enable = true;

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

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

  services.flatpak.packages = [
    "nz.mega.MEGAsync"
    "md.obsidian.Obsidian"
    "com.bitwarden.desktop"
    "org.prismlauncher.PrismLauncher"
  ];
  # services.flatpak.overrides = { };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
  home.packages = with pkgs; [
    ## Programs
    webcord-vencord

    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    ## Fonts
    fira-code
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  fonts.fontconfig.enable = true;


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/guz/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };
}





