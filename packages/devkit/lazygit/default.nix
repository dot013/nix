{
  symlinkJoin,
  makeWrapper,
  pkgs,
  lib,
  lazygit ? pkgs.lazygit,
  settings ? {},
}: let
  # YAML is a superset of JSON, so any JSON is valid YAML.
  colors = import ../colors.nix;
  cfg = pkgs.writeText "config.yml" (builtins.toJSON ({
      git.paging.colorArg = "always";
      git.paging.pager = "${lib.getExe pkgs.delta} --dark --paging=never";

      gui.theme = {
        activeBorderColor = [colors.base07 "bold"];
        inactiveBorderColor = [colors.base04];
        searchingActiveBorderColor = [colors.base02 "bold"];
        optionsTextColor = [colors.base06];
        selectedLineBgColor = [colors.base03];
        cherryPickedCommitBgColor = [colors.base02];
        cherryPickedCommitFgColor = [colors.base03];
        unstagedChangesColor = [colors.base08];
        defaultFgColor = [colors.base05];
      };
    }
    // settings));

  drv = symlinkJoin ({
      paths = [lazygit];

      nativeBuildInputs = [makeWrapper];

      postBuild = ''
        wrapProgram $out/bin/lazygit \
          --add-flags '--use-config-file' --add-flags '${cfg}'
      '';
    }
    // {inherit (lazygit) name pname meta;});
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
    // {inherit (lazygit) meta;})
