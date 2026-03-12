{config, ...}: {
  programs.qutebrowser.profiles = let
    art = config.programs.qutebrowser.profiles."art";
    work = config.programs.qutebrowser.profiles."work";
  in {
    # HACK: `inherit` is being used to prevent infinite recursion
    "art-2" = {inherit (art) settings searchEngines;};
    "art-3" = {inherit (art) settings searchEngines;};
    "work-2" = {inherit (work) settings searchEngines;};
    "work-3" = {inherit (work) settings searchEngines;};
  };

  # The *state version* indicates which default
  # settings are in effect and will therefore help avoid breaking
  # program configurations. Switching to a higher state version
  # typically requires performing some manual steps, such as data
  # conversion or moving files.
  home.stateVersion = "24.11";
}
