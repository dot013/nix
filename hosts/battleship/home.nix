{...}: {
  imports = [
    ../../modules/home-manager
    ./packages.nix
    ./desktop
    ../../modules/home-manager/programs-old/librewolf
  ];

  profiles.gterminal.enable = true;
  profiles.vault.enable = true;
  profiles.gfonts.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"

      export GPG_TTY=$(tty)
    '';
  };

  services.gnome-keyring.enable = true;

  programs.prismlauncher.enable = true;

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
