{
  symlinkJoin,
  makeWrapper,
  pkgs,
  lib,
  ghostty ? pkgs.ghostty,
  command ? null,
}: let
  colors = import ./colors.nix;
  theme = with colors;
    pkgs.writeText "theme" ''
      palette = 0=${base00}
      palette = 1=${base08}
      palette = 2=${base0B}
      palette = 3=${base0A}
      palette = 4=${base0D}
      palette = 5=${base0E}
      palette = 6=${base0C}
      palette = 7=${base05}
      palette = 8=${base03}
      palette = 9=${base08}
      palette = 10=${base0B}
      palette = 11=${base0A}
      palette = 12=${base0D}
      palette = 13=${base0E}
      palette = 14=${base0C}
      palette = 15=${base07}

      background = ${base00}
      foreground = ${base05}
      cursor-color = ${base05}
      selection-background = ${base02}
      selection-foreground = ${base07}
    '';
in
  symlinkJoin ({
      paths = [ghostty];

      nativeBuildInputs = [makeWrapper];

      postBuild = ''
        wrapProgram $out/bin/ghostty \
          --add-flags '--theme=${theme}' ${
          if !(isNull command)
          then "--add-flags '-e' --add-flags '${command}'"
          else ""
        }
      '';
    }
    // {inherit (ghostty) name pname meta shell_integration terminfo;})
