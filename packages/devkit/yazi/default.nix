{
  symlinkJoin,
  makeWrapper,
  pkgs,
  lib,
  yazi ? pkgs.yazi,
}: let
  drv = symlinkJoin ({
      paths = yazi;

      nativeBuildInputs = [makeWrapper];

      postBuild = ''
        wrapProgram $out/bin/yazi \
          --set-default YAZI_CONFIG_HOME ${./.}
      '';
    }
    // {inherit (yazi) name pname meta;});
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
    // {inherit (yazi) meta;})
