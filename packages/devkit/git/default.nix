{
  symlinkJoin,
  makeWrapper,
  pkgs,
  lib,
  git ? pkgs.git,
}: let
  drv = symlinkJoin ({
      paths = git;

      nativeBuildInputs = [makeWrapper];

      postBuild = ''
        wrapProgram $out/bin/git \
          --set-default 'GIT_CONFIG_COUNT' 7 \
          --set-default 'GIT_CONFIG_KEY_0' 'core.pager' \
          --set-default 'GIT_CONFIG_VALUE_0' '${lib.getExe pkgs.delta}' \
          --set-default 'GIT_CONFIG_KEY_1' 'credentials.helper' \
          --set-default 'GIT_CONFIG_VALUE_1' 'store' \
          --set-default 'GIT_CONFIG_KEY_2' 'interactive.diffFilter' \
          --set-default 'GIT_CONFIG_VALUE_2' '${lib.getExe pkgs.delta} --color-only' \
          --set-default 'GIT_CONFIG_KEY_3' 'signing.signByDefault' \
          --set-default 'GIT_CONFIG_VALUE_3' 'true' \
          --set-default 'GIT_CONFIG_KEY_4' 'user.email' \
          --set-default 'GIT_CONFIG_VALUE_4' 'contact@guz.one' \
          --set-default 'GIT_CONFIG_KEY_5' 'user.name' \
          --set-default 'GIT_CONFIG_VALUE_5' 'Gustavo "Guz" L de Mello' \
          --set-default 'GIT_CONFIG_KEY_6' 'commit.gpgsign' \
          --set-default 'GIT_CONFIG_VALUE_6' 'true'
      '';
    }
    // {inherit (git) name pname meta;});
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
    // {inherit (git) meta;})
