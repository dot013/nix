{
  inputs,
  lib,
  osConfig,
  pkgs,
  self,
  ...
}: {
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    self.homeManagerModules.devkit
    self.homeManagerModules.godot

    ./browser.nix
    ./desktop.nix
    ./impermanence.nix
  ];

  services.flatpak.enable = true;
  services.flatpak.packages = [
    "org.kde.krita"
    "org.vinegarhq.Sober"
  ];

  home.packages =
    # Programs
    (with pkgs; [
      self.packages.${pkgs.stdenv.hostPlatform.system}.audacity
      blender
      bitwarden-desktop
      inkscape
      nextcloud-client
      obsidian
      prismlauncher

      # System
      pwvucontrol
      xorg.xprop # Annoying notification if it is not found
    ])
    # Fonts
    ++ (with pkgs; [
      google-fonts
      nerd-fonts.fira-code
      self.packages.${pkgs.stdenv.hostPlatform.system}.cal-sans
    ]);

  # Element (Matrix)
  programs.element-desktop.enable = true;

  # Godot
  programs.godot.enable = true;

  # OBS Studio
  programs.obs-studio.enable = true;

  # Vesktop (Discord)
  programs.vesktop.enable = true;
  programs.vesktop.vencord.settings = {
    autoUpdate = false;
    autoUpdateNotification = false;
    disableMinSize = true;
    enabledThemes = ["no-extra.css" "no-nitro.css"];
    notifyAboutUpdates = false;
    plugins = {
      CrashHandler.enabled = true;
      Dearrow.enabled = true;
      FakeNitro.enabled = true;
      FixYoutubeEmbeds.enabled = true;
      NoTypingAnimation.enabled = true;
      petpet.enabled = true;
      PinDMs.enabled = true;
      VoiceMessages.enabled = true;
      WebKeybinds.enabled = true;
      WebScreenShareFixes.enabled = true;
      YoutubeAdblock.enabled = true;
    };
  };
  programs.vesktop.vencord.themes = {
    "no-extra" = pkgs.fetchurl {
      url = "https://code.capytal.cc/guz013/no-bullshit-discord.css/raw/branch/main/no-extra.css";
      hash = "sha256-IXFpptElljrt0G7NtNvPTCa2SORjwzGFY1Frll0FUUo=";
    };
    "no-nitro" = pkgs.fetchurl {
      url = "https://code.capytal.cc/guz013/no-bullshit-discord.css/raw/branch/main/no-nitro.css";
      hash = "sha256-ouHW4KL+Jn5ERfFRcw7n15bWnzea7/lCLr4h0PsPQA8=";
    };
  };

  # Open Tablet Driver configuration
  xdg.configFile."OpenTabletDriver/settings.json" = lib.mkIf osConfig.hardware.opentabletdriver.enable {
    force = true;
    text = builtins.toJSON {
      Profiles = let
        mkBinding = k: {
          Path = "OpenTabletDriver.Desktop.Binding.${
            if lib.hasInfix "+" k
            then "MultiKeyBinding"
            else "KeyBinding"
          }";
          Settings = [
            {
              Property =
                if lib.hasInfix "+" k
                then "Keys"
                else "Key";
              Value = k;
            }
          ];
          Enable = true;
        };
      in [
        {
          Tablet = "Huion HS610";
          OutputMode.Path = "OpenTabletDriver.Desktop.Output.LinuxArtistMode";
          OutputMode.Settings = [];
          OutputMode.Enable = true;
          Filters = [];
          AbsoluteModeSettings.Display = {
            Width = 1720.0;
            Height = 1080.0;
            X = 1280.0;
            Y = 540.0;
            Rotation = 0.0;
          };
          AbsoluteModeSettings.Tablet = {
            Width = 254.0;
            Height = 158.75;
            X = 127.0;
            Y = 79.375;
            Rotation = 0;
          };
          AbsoluteModeSettings.EnableClipping = true;
          AbsoluteModeSettings. EnableAreaLimiting = false;
          AbsoluteModeSettings. LockAspectRatio = false;
          RelativeModeSettings = {
            XSensitivity = 10.0;
            YSensitivity = 10.0;
            RelativeRotation = 0.0;
            RelativeResetDelay = "00:00:00.1000000";
          };
          Bindings.TipActivationThreshold = 1.0;
          Bindings.TipButton = {
            Path = "OpenTabletDriver.Desktop.Binding.MouseBinding";
            Settings = [
              {
                Property = "Button";
                Value = "Left";
              }
            ];
          };
          Bindings.EraserActivationThreshold = 1.0;
          Bindings.EraserButton = null;
          Bindings.PenButtons = [
            (mkBinding "Space")
            (mkBinding "Control+K")
          ];
          Bindings.AuxButtons = [
            null
            null
            null
            null
            (mkBinding "D5")
            null
            (mkBinding "LeftControl")
            (mkBinding "LeftShift")
            (mkBinding "Control+Z")
            (mkBinding "Control+Shift+Z")
            (mkBinding "B")
            (mkBinding "E")
          ];
          Bindings.MouseButtons = [];
          Bindings.MouseScrollUp = null;
          Bindings.MouseScrollDown = null;
        }
      ];
      LockUsableAreaDisplay = true;
      LockUsableAreaTablet = true;
      Tools = [];
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
