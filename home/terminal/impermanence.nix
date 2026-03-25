{lib, ...}:
with lib; {
  home.persistence."/persist" = {
    directories = map (d:
      if isList d
      then {
        directory = elemAt d 1;
        mode = elemAt d 0;
      }
      else d) [
      ["0755" "Academic"]
      ["0755" "Documents"]
      ["0755" "Downloads"]
      ["0755" "Job"]
      ["0755" "KritaRecorder"]
      ["0755" "Music"]
      ["0755" "Nextcloud"]
      ["0755" "Projects"]
      ["0755" "Pictures"]
      ["0755" "Videos"]
      ["0755" "go"]
      ["0700" ".gnupg"]
      ["0700" ".ssh"]
      ["0755" ".steam"]
      ["0755" ".cache/Audacity"]
      ["0755" ".cache/blender"]
      ["0755" ".cache/flatpak"]
      ["0755" ".cache/go-build"]
      ["0755" ".cache/godot"]
      ["0700" ".cache/gopls"]
      ["0755" ".cache/nvim"]
      ["0755" ".cache/starship"]
      ["0700" ".cache/vivaldi"]
      ["0700" ".cache/wezterm"]
      ["0755" ".cache/zellij"]
      ["0700" ".cache/zen"]
      ["0755" ".config/Audacity"]
      ["0755" ".config/audacity4"]
      ["0755" ".config/blender"]
      ["0751" ".config/inkscape"]
      ["0600" ".config/kritarc"]
      ["0644" ".config/kritadisplayrc"]
      ["0755" ".config/sops/age"]
      ["0755" ".config/vivaldi"]
      ["0755" ".config/zen"]
      ["0755" ".local/lib/vivaldi"]
      ["0755" ".local/share/Audacity"]
      ["0755" ".local/share/audacity4"]
      ["0755" ".local/share/direnv"]
      ["0755" ".local/share/flatpak"]
      ["0700" ".local/share/keyrings"]
      ["0700" ".local/share/Steam"]
    ];
  };
}
