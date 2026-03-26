{
  symlinkJoin,
  makeWrapper,
  pkgs,
  lib,
  ghostty ? pkgs.ghostty,
  command ? null,
}: let
  colors = import ./colors.nix;
  config = with colors; {
    background = base00;
    background-opacity = 0.9;
    cursor-color = base05;
    foreground = base05;
    gtk-titlebar = false;
    gtk-titlebar-hide-when-maximized = true;
    palette = [
      "0=${base00}"
      "1=${base08}"
      "2=${base0B}"
      "3=${base0A}"
      "4=${base0D}"
      "5=${base0E}"
      "6=${base0C}"
      "7=${base05}"
      "8=${base03}"
      "9=${base08}"
      "10=${base0B}"
      "11=${base0A}"
      "12=${base0D}"
      "13=${base0E}"
      "14=${base0C}"
      "15=${base07}"
    ];
    selection-background = base02;
    selection-foreground = base07;
  };
in
  symlinkJoin ({
      paths = [ghostty];
      nativeBuildInputs = [makeWrapper pkgs.coreutils];
      postBuild = ''
        wrapProgram $out/bin/ghostty ${
          with lib;
            pipe config [
              (mapAttrsToList
                (n: v:
                  if isList v
                  then (map (v: ["--add-flags" "--${n}='${toString v}'"]) v)
                  else ["--add-flags" "--${n}='${toString v}'"]))
              flatten
              escapeShellArgs
            ]
        } ${
          if !(isNull command)
          then "--add-flags '-e' --add-flags '${command}'"
          else ""
        }
        sed -i \
          "s|Exec=.*|Exec=$out/bin/ghostty --gtk-single-instance=true|" \
          $out/share/applications/com.mitchellh.ghostty.desktop
        sed -i \
          "s|TryExec=.*|TryExec=$out/bin/ghostty|" \
          $out/share/applications/com.mitchellh.ghostty.desktop
      '';
    }
    // {inherit (ghostty) name pname meta shell_integration terminfo;})
