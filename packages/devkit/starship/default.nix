{
  symlinkJoin,
  makeWrapper,
  pkgs,
  lib,
  starship ? pkgs.starship,
}: let
  drv = symlinkJoin ({
      paths = [starship];

      nativeBuildInputs = [makeWrapper];

      postBuild = ''
        wrapProgram $out/bin/starship \
          --set-default 'STARSHIP_CONFIG' '${./config.toml}'
      '';
    }
    // {inherit (starship) name pname meta;});
in
  pkgs.stdenv.mkDerivation (rec {
      name = drv.name;
      pname = drv.pname;

      buildCommand = let
        desktopEntry = pkgs.makeDesktopItem {
          name = pname;
          desktopName = name;
          exec = "${lib.getExe drv}";
          terminal = true;
        };
      in ''
        mkdir -p $out/bin
        cp ${lib.getExe drv} $out/bin

        mkdir -p $out/share/applications
        cp ${desktopEntry}/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
      '';
    }
    // {inherit (starship) meta;})
