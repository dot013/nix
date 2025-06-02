{
  symlinkJoin,
  makeWrapper,
  pkgs,
  lib,
  ghostty ? pkgs.ghostty,
}: let
  colors = import ../colors.nix;
  theme = pkgs.writeText "theme" ''
    palette = 0=${colors.base00}
    palette = 1=${colors.base08}
    palette = 2=${colors.base0B}
    palette = 3=${colors.base0A}
    palette = 4=${colors.base0D}
    palette = 5=${colors.base0E}
    palette = 6=${colors.base0C}
    palette = 7=${colors.base05}
    palette = 8=${colors.base03}
    palette = 9=${colors.base08}
    palette = 10=${colors.base0B}
    palette = 11=${colors.base0A}
    palette = 12=${colors.base0D}
    palette = 13=${colors.base0E}
    palette = 14=${colors.base0C}
    palette = 15=${colors.base07}

    background = ${colors.base00}
    foreground = ${colors.base05}
    cursor-color = ${colors.base05}
    selection-background = ${colors.base02}
    selection-foreground = ${colors.base07}
  '';
  drv = symlinkJoin ({
      paths = [ghostty];

      nativeBuildInputs = [makeWrapper];

      postBuild = ''
        wrapProgram $out/bin/ghostty \
          --add-flags '--theme=${theme}'
      '';
    }
    // {inherit (ghostty) name pname meta man shell_integration terminfo;});
in
  pkgs.stdenv.mkDerivation (rec {
      name = drv.name;
      pname = drv.pname;

      buildCommand = let
        desktopEntry = pkgs.makeDesktopItem {
          name = pname;
          desktopName = name;
          exec = "${lib.getExe drv}";
        };
      in ''
        mkdir -p $out/bin
        cp ${lib.getExe drv} $out/bin

        mkdir -p $out/share/applications
        cp ${desktopEntry}/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
      '';
    }
    // {inherit (ghostty) meta man shell_integration terminfo;})
