{
  nixos = {inputs, ...}: {
    nixpkgs.overlays = [inputs.obsidian-extensions.overlays.default];
  };
  homeManager = {
    lib,
    pkgs,
    ...
  }:
    with lib; {
      programs.obsidian.enable = true;
      programs.obsidian.defaultSettings = {
        app = {
          alwaysUpdateLinks = true;
          spellcheck = true;
          vimMode = true;
          settingsPopoutWindow = false;
          livePreview = false;
          useTab = false;
          tabSize = 2;
          useMarkdownLinks = true;
          trashOption = "local";
        };
        appearance = {
          baseFontSize = mkForce 16;
          enabledCssSnippets = ["Stylix Config"];
          interfaceFontFamily = mkForce "Red Hat Display,Dejavu Sans";
          monospaceFontFamily = mkForce "Fira Code,Dejavu Sans";
          textFontFamily = mkForce "Red Hat Text";
        };
        corePlugins = [
          "backlink"
          "bases"
          "canvas"
          "command-palette"
          "daily-notes"
          "file-recovery"
          "file-explorer"
          "graph"
          "global-search"
          "markdown-importer"
          "note-composer"
          "outgoing-link"
          "outline"
          "page-preview"
          "properties"
          "switcher"
          "templates"
        ];
        communityPlugins = with pkgs.obsidianPlugins; let
          plugins = [
            {
              pkg = advanced-line-numbers;
              startupType = "short";
              settings = {
                mode = "hybrid";
                showCursorPositionInStatusBar = true;
                showActiveLineHighlight = false;
              };
            }
            {
              pkg = dataview;
              startupType = "short";
            }
            {
              pkg = maps;
              startupType = "long";
            }
            {
              pkg = obsidian-hider;
              startupType = "long";
            }
            {
              pkg = obsidian-minimal-settings;
              startupType = "short";
            }
            {
              pkg = obsidian-tasks-plugin;
              startupType = "short";
            }
            {
              pkg = rumdl;
              settings = {
                formatOnSave = true;
                showStatusBar = true;
                disabledRules = ["MD041"];
                useConfigFile = false;
                lineLenght = 80;
                headingStyle = "atx";
                emphasisStyle = "asterisk";
                ulStyle = "dash";
              };
              startupType = "long";
            }
            {
              pkg = source-mode-inline-images;
              startupType = "long";
            }
            {
              pkg = table-editor-obsidian;
              startupType = "long";
            }
            {
              pkg = tasks-caldav-sync;
              startupType = "long";
            }
            {
              pkg = templater-obsidian;
              startupType = "long";
            }
            {
              pkg = typewriter-mode;
              startupType = "short";
            }
            {
              pkg = vim-motions;
              startupType = "short";
            }
            {
              pkg = vim-yank-highlight;
              startupType = "short";
            }
          ];
        in
          (map (v: removeAttrs v ["startupType"]) plugins)
          ++ [
            {
              pkg = lazy-plugins;
              settings = {
                dualConfigs = false;
                showConsoleLog = false;
                desktop.shortDelaySeconds = 5;
                desktop.longDelaySeconds = 15;
                desktop.delayBetweenPlugins = 40;
                desktop.defaultStartupType = "short";
                desktop.showDescriptions = true;
                desktop.enableDependencies = false;
                desktop.plugins = listToAttrs (map (v: {
                    name = removePrefix "obsidian-plugin-" (getName v.pkg);
                    value = {startupType = v.startupType;};
                  })
                  plugins);
              };
            }
          ];
      };
      programs.obsidian.vaults = {
        Notes.target = "Nextcloud/Notes";
      };

      stylix.targets.obsidian.vaultNames = ["Notes"];
    };
}
