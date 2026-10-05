{
  nixos = {self, ...}: {
    imports = [
      self.nixosModules.features.gnome
    ];
  };
  homeManager = {
    config,
    lib,
    pkgs,
    pkgs-unstable,
    self,
    ...
  }:
    with lib; {
      imports = [
        self.homeManagerModules.features.gnome
      ];
      programs.gnome-shell.extensions = with pkgs-unstable.gnomeExtensions; [
        {package = arcmenu;}
        {package = forge;}
      ];

      dconf.enable = true;
      dconf.settings = {
        "org/gnome/desktop/wm/keybindings" = {
          close = ["<Super>C"];
          minimize = [];
          move-to-workspace-1 = ["<Shift><Super>1"];
          move-to-workspace-2 = ["<Shift><Super>2"];
          move-to-workspace-3 = ["<Shift><Super>3"];
          move-to-workspace-4 = ["<Shift><Super>4"];
          move-to-workspace-5 = ["<Shift><Super>5"];
          switch-to-workspace-1 = ["<Super>1"];
          switch-to-workspace-2 = ["<Super>2"];
          switch-to-workspace-3 = ["<Super>3"];
          switch-to-workspace-4 = ["<Super>4"];
          switch-to-workspace-5 = ["<Super>5"];
          toggle-quick-settings = [];
        };
        "org/gnome/desktop/wm/preferences" = {
          focus-mode = "mouse";
        };
        "org/gnome/shell/extensions/arcmenu" = {
          menu-button-appearance = "None";
          runner-hotkey = ["<Super>S"];
          runner-position = "Centered";
          runner-show-frequent-apps = true;
          show-activities-button = true;
        };
        "org/gnome/shell/extensions/forge" = {
          dnd-center-layout = "stacked";
          focus-on-hover-enabled = true;
          tabbed-tiling-mode-enabled = false;
          move-pointer-focus-enabled = true;
          window-toggle-float = ["<Shift><Super>F"];
          window-toggle-always-float = [""];
        };
        "org/gnome/shell/keybindings" =
          # Remove keybindings for things such as Calendar, File Explorer, etc
          (genAttrs (map
            (n: "switch-to-application-${toString n}")
            (range 1 9))
          (n: []))
          // (genAttrs (map
            (n: "open-new-window-application-${toString n}")
            (range 1 9))
          (n: []));
        "org/gnome/mutter" = {
          dynamic-workspaces = false;
          num-workspaces = 5;
          workspace-only-on-primary = true;
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>q";
          command = getExe config.programs.ghostty.package;
          name = "Launch Ghostty";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = mkIf config.programs.obsidian.enable {
          binding = "<Super>n";
          command = getExe config.programs.obsidian.package;
          name = "Launch Obsidian";
        };
      };
    };
}
