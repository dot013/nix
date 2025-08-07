{
  self,
  config,
  ...
}: {
  programs.qutebrowser.profiles = let
    programmingSearchEngines = {
      # Languages
      go = "https://pkg.go.dev/search?q={}";

      # Resources
      mdn = "https://developer.mozilla.org/en-US/search?q={}";
    };
  in rec {
    work = {
      settings = {
        colors.tabs.selected.even.bg = "#74C7EC"; # Catppuccin's Sapphire
        colors.tabs.selected.odd.bg = "#74C7EC"; # Catppuccin's Sapphire
        colors.tabs.pinned.selected.even.bg = "#74C7EC"; # Catppuccin's Sapphire
        colors.tabs.pinned.selected.odd.bg = "#74C7EC"; # Catppuccin's Sapphire
      };
      searchEngines = programmingSearchEngines;
    };
    work-2 = work;
    work-3 = work;
    work-video = work;
    work-games = {
      settings = work.settings;
      searchEngines =
        {
          mod = "https://modrinth.com/mods?q={}";
          rcp = "https://modrinth.com/resourcepacks?q={}";
          dtp = "https://modrinth.com/datapacks?q={}";
          shader = "https://modrinth.com/shaders?q={}";
          modpack = "https://modrinth.com/modpacks?q={}";
          plugins = "https://modrinth.com/plugins?q={}";
        }
        // work.searchEngines;
    };
  };
  # The *state version* indicates which default
  # settings are in effect and will therefore help avoid breaking
  # program configurations. Switching to a higher state version
  # typically requires performing some manual steps, such as data
  # conversion or moving files.
  home.stateVersion = "24.11";
}
