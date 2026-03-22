{
  lib,
  makeWrapper,
  pkgs,
  replaceVarsWith,
  stdenv,
  symlinkJoin,
  zsh ? pkgs.zsh,
  zshrc-prepend ? "",
  zshrc-append ? "",
}: let
  zdotdir = stdenv.mkDerivation {
    name = "zdotdir";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out
      cp ${replaceVarsWith {
        src = ./.zshrc;
        replacements = {
          "zsh-plugin-autosuggestions" = ''
            # Auto Suggestions
            source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh";
            ZSH_AUTOSUGGEST_STRATEGY=(history)
          '';
          "zsh-plugin-syntaxhighlighing" = ''
            # Syntax Highlighting
            source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
            ZSH_HIGHLIGHT_HIGHLIGHTERS+=(${lib.concatStringsSep " " (map lib.escapeShellArg ["brackets"])})
          '';
          "zshrc-prepend" = ''
            # Zsh Prepend
            ${zshrc-prepend}
          '';
          "zshrc-append" = ''
            # Zsh Append
            ${zshrc-append}
          '';
        };
        postCheck = ''${stdenv.shellDryRun} "$target"'';
      }} $out/.zshrc
      cp ${./.zshenv} $out/.zshenv
    '';
  };
in
  symlinkJoin {
    paths = [zsh];
    nativeBuildInputs = [makeWrapper];
    postBuild = ''
      mkdir -p $out
      wrapProgram $out/bin/zsh --set-default 'ZDOTDIR' '${zdotdir}'
    '';
    inherit (zsh) man meta name passthru pname version;
  }
