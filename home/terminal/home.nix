{
  lib,
  osConfig,
  pkgs,
  self,
  ...
}: {
  imports = [
    self.homeManagerModules.devkit

    ./browser.nix
    ./desktop.nix
    ./impermanence.nix
  ];

  home.packages =
    # Programs
    (with pkgs; [
      self.packages.${pkgs.stdenv.hostPlatform.system}.audacity
      blender
      bitwarden-desktop
      godot
      inkscape
      krita
      nextcloud-client
      obsidian
      prismlauncher

      # System
      pwvucontrol
    ])
    # Fonts
    ++ (with pkgs; [
      google-fonts
      nerd-fonts.fira-code
      self.packages.${pkgs.stdenv.hostPlatform.system}.cal-sans
    ]);

  home.file = let
    godottemplates = pkgs.godot-export-templates-bin;
    godotname = builtins.replaceStrings ["-"] ["."] godottemplates.version;
  in {
    ".local/share/godot/export_templates/${godotname}" = {
      source = "${godottemplates}/share/godot/export_templates/${godotname}";
    };
  };

  # OBS Studio
  programs.obs-studio.enable = true;

  # Vesktop (Discord)
  programs.vesktop.enable = true;

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
