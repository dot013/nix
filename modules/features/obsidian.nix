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
      };
      programs.obsidian.vaults.Notes = {
        target = "Nextcloud/Notes";
        settings = {
          cssSnippets = [
            {
              name = "radix-colors";
              text = replaceString ".dark-theme" ".theme-dark" (join "\n\n" (map (v: ''
                  ${readFile (pkgs.fetchurl {
                    url = "https://cdn.jsdelivr.net/npm/@radix-ui/colors@3.0.0/${elemAt v 0}-dark.css";
                    hash = elemAt v 1;
                  })}
                '') [
                  ["amber" "sha256-sfhM5cuDNrVMkmx4u4l4ffVtK74nfc1qRT0W0HTXQBM="]
                  ["iris" "sha256-pYA1FWFu9+SEq53GcT2bV9JgRcZLrScDa3c7VnUa3Ho="]
                  ["red" "sha256-xlpDQL8xCj83RzotsZhuwOevNftBVB9jsQNkJAx4JeE="]
                  ["yellow" "sha256-a3WGYYXyi6316c60KoHZZwwhDCg6Bc/oPqrHG9/JUDQ="]
                  ["blue" "sha256-aicyTyrX1TZJ1Avd/Tl9snbU+thiaUX9VNkDGQuljCM="]
                  ["cyan" "sha256-xt7yOu07nf7AKTeI4GJ2nuMJ+fEmqMuewBxOd61KMsg="]
                  ["green" "sha256-LOuwA4j9hKQeOcUcGEKTuM8u7rRCSUbn+m+aupsrXew="]
                  ["grass" "sha256-/Vra/sEm6qqqD6riMVGa28mLJvqmIRzBd33uLK7srTM="]
                  ["tomato" "sha256-mRjbc08ryeAlr4wYnyUTMMvr1JDHIdlMtqJxhs45DvQ="]
                ]));
            }
            {
              name = "folder-colors";
              text = ''
                .nav-file-title[data-path^="areas"],
                .nav-folder-title[data-path^="areas"] {
                  color: var(--iris-11);
                  &:hover {
                    color: var(--iris-12);
                  }
                }
                .nav-file-title[data-path^="fleeting"],
                .nav-folder-title[data-path^="fleeting"] {
                  color: var(--yellow-11);
                  &:hover {
                    color: var(--yellow-12);
                  }
                }
                .nav-file-title[data-path^="periodic"],
                .nav-folder-title[data-path^="periodic"] {
                  color: var(--red-11);
                  &:hover {
                    color: var(--red-12);
                  }
                }
                .nav-file-title[data-path^="projects"],
                .nav-folder-title[data-path^="projects"] {
                  color: var(--cyan-11);
                  &:hover {
                    color: var(--cyan-12);
                  }
                }
                .nav-file-title[data-path^="resources"],
                .nav-folder-title[data-path^="resources"] {
                  color: var(--green-11);
                  &:hover {
                    color: var(--green-12);
                  }
                }
              '';
            }
          ];
          corePlugins = [
            "backlink"
            "bases"
            "canvas"
            "command-palette"
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
                pkg = heatmap-calendar;
                startupType = "long";
              }
              {
                pkg = maps;
                startupType = "long";
              }
              {
                pkg = obsidian-front-matter-title-plugin;
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
                pkg = quickadd;
                startupType = "long";
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
                pkg = periodic-notes;
                settings = {
                  showGettingStartedBanner = false;
                  hasMigratedDailyNoteSettings = false;
                  hasMigratedWeeklyNoteSettings = false;
                  daily = {
                    format = "[periodic/]YYYY/YYYY-[Q]Q/YYYY-MM/gggg-[W]WW/YYYY-MM-DD";
                    folder = "";
                    template = "_templates/daily.md";
                    enabled = true;
                  };
                  weekly = {
                    format = "[periodic/]gggg/gggg-[Q]Q/gggg-MM/gggg-[W]WW/gggg-[W]WW";
                    folder = "";
                    template = "_templates/weekly.md";
                    enabled = true;
                  };
                  monthly = {
                    format = "[periodic/]YYYY/YYYY-[Q]Q/YYYY-MM/YYYY-MM";
                    folder = "";
                    template = "_templates/monthly.md";
                    enabled = true;
                  };
                  quarterly = {
                    format = "[periodic/]YYYY/YYYY-[Q]Q/YYYY-[Q]Q";
                    folder = "";
                    template = "_templates/quarterly.md";
                    enabled = true;
                  };
                  yearly = {
                    format = "[periodic/]YYYY/YYYY";
                    folder = "";
                    template = "_templates/yearly.md";
                    enabled = true;
                  };
                };
                startupType = "short";
              }
              {
                pkg = simple-banner;
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
      };

      stylix.targets.obsidian.vaultNames = ["Notes"];
    };
}
