{
  symlinkJoin,
  makeWrapper,
  pkgs,
  lib,
  zsh ? pkgs.zsh,
  # .zshrc
  zshrc-prepend ? "",
  zshrc-append ? "",
}: let
  zsh-syntax-highlighting = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
  zsh-autosuggestions = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh";

  zshrc-prepend-file = pkgs.writeText ".zshrc_prepend" zshrc-prepend;
  zshrc-append-file = pkgs.writeText ".zshrc_append" zshrc-append;

  drv = symlinkJoin ({
      paths = zsh;

      nativeBuildInputs = [makeWrapper];

      postBuild = ''
        wrapProgram $out/bin/zsh \
          --set-default 'ZSH_PLUGIN_SYNTAXHIGHLIGHING' '${zsh-syntax-highlighting}' \
          --set-default 'ZSH_PLUGIN_AUTOSUGGESTIONS' '${zsh-autosuggestions}' \
          --set-default 'ZSHRC_PREPEND' '${zshrc-prepend-file}' \
          --set-default 'ZSHRC_APPEND' '${zshrc-append-file}' \
          --set-default 'ZDOTDIR' '${./.}'
      '';
    }
    // {inherit (zsh) name pname meta man;});
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
    // {inherit (zsh) meta man;})
