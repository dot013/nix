{lib, ...}:
with lib; {
  home.persistence."/persist" = {
    directories = map (d:
      if isList d
      then {
        directory = elemAt 1 d;
        mode = elemAt 0 d;
      }
      else d) [
      ["0755" "Documents"]
      ["0755" "Downloads"]
      ["0755" "KritaRecorder"]
      ["0755" "Music"]
      ["0755" "Nextcloud"]
      ["0755" "Projects"]
      ["0755" "Pictures"]
      ["0755" "Videos"]
      ["0755" "go"]
      ["0700" ".gnupg"]
      ["0700" ".ssh"]
      ["0755" ".cache/blender"]
      ["0755" ".cache/go-build"]
      ["0755" ".cache/godot"]
      ["0700" ".cache/gopls"]
      ["0755" ".cache/nvim"]
      ["0700" ".cache/qutebrowser"]
      ["0755" ".cache/starship"]
      ["0700" ".cache/wezterm"]
      ["0755" ".cache/zellij"]
      ["0755" ".config/blender"]
      ["0751" ".config/inkscape"]
      ["0600" ".config/kritarc"]
      ["0644" ".config/kritadisplayrc"]
      ["0755" ".config/qutebrowser"]
      ["0755" ".local/share/direnv"]
      ["0700" ".local/share/keyrings"]
    ];
  };
}
