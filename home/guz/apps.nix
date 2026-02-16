{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  self,
  ...
}: {
  services.flatpak.packages = [
    # Management
    "com.bitwarden.desktop"
    "com.rustdesk.RustDesk"

    # Services
    "app.moosync.moosync"

    # Games
    # "org.prismlauncher.PrismLauncher"
    # "net.pcsx2.PCSX2" Currently borked, mising qt plugin/platform
    "org.vinegarhq.Sober"

    # Office
    "org.libreoffice.LibreOffice"

    # Media creation
    "com.nextcloud.desktopclient.nextcloud"
    "fr.natron.Natron"
    "org.beeref.BeeRef"
    "com.github.vikdevelop.photopea_app"
    "org.darktable.Darktable"
    "org.inkscape.Inkscape"
    # "org.kde.krita" Currently borked, mising qt plugin/platform
    "com.obsproject.Studio"
    "org.kde.kdenlive"
    # "fm.reaper.Reaper"

    # 3D modeling
    "net.blockbench.Blockbench"
  ];
  services.flatpak.overrides = {
    "net.blockbench.Blockbench" = {Context.sockets = ["x11"];};
    "com.bitwarden.desktop" = {Context.sockets = ["x11"];};
    "fr.natron.Natron" = {Context.sockets = ["x11"];};
    "com.github.vikdevelop.photopea_app" = {Context.sockets = ["x11"];};
    "org.prismlauncher.PrismLauncher" = {Context.sockets = ["x11"];};
    "org.vinegarhq.Sober" = {Context.device = "input";};
    "dev.vencord.Vesktop" = {Context.sockets = ["x11"];};
  };

  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true;

  qt.enable = true;
  home.packages =
    (with pkgs; [
      # Management
      megasync

      # Games
      lutris
      winePackages.waylandFull
      pcsx2
      prismlauncher
      mono # For city skylines mods

      # Social
      webcord

      # Keyboard
      vial

      pkgs-unstable.davinci-resolve

      blender
      (callPackage ({
        pkgs,
        makeWrapper,
        symlinkJoin,
        ...
      }:
        symlinkJoin {
          inherit (pkgs.godot) name pname meta man;
          paths = [pkgs.godot];
          nativeBuildInputs = [makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/godot \
              --add-flags '--single-window'
          '';
        }) {})

      android-studio
      android-tools
      androidenv.androidPkgs.androidsdk
      androidenv.androidPkgs.emulator
      androidenv.androidPkgs.ndk-bundle
    ])
    ++ (with self.packages.${pkgs.system}; [
      davincify
      audacity4
      untrack
    ]);

  home.file = let
    templates = pkgs.godot-export-templates-bin;
    name = builtins.replaceStrings ["-"] ["."] templates.version;
  in {
    ".bin/blender" = {
      source = lib.getExe pkgs.blender;
    };
    ".local/share/godot/export_templates/${name}" = {
      source = "${templates}/share/godot/export_templates/${name}";
    };
  };

  neovim.integrations.godot.enable = true;

  xdg.desktopEntries."davinci-resolve-zsh" = rec {
    name = "Davinci Resolve (Zsh)";
    genericName = name;
    mimeType = ["application/x-resolveproj"];
    # INFO: For some reason this works and removes the "Unsupported GPU" error
    exec = "${lib.getExe config.programs.zsh.package} -c ${lib.getExe pkgs-unstable.davinci-resolve}";
  };

  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      # Godot
      "tile,initialTitle:^(Godot)$,initialClass:^(Godot)$" # Main editor tiled
      # Everything else float
      "float,title:^((.*)(DEBUG)),initialClass:^(Godot)$,initialTitle:^(.*)(DEBUG)(.*)$,class:^(Godot)$"
    ];
  };

  services.easyeffects.enable = true;

  # TODO: Remove this
  programs.distrobox.enable = true;
  programs.distrobox.containers = {
    "davincibox" = {
      image = "ghcr.io/zelikos/davincibox-opencl:latest";
    };
  };
}
