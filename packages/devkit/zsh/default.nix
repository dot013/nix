{
  symlinkJoin,
  makeWrapper,
  pkgs,
  zsh ? pkgs.zsh,
  # .zshrc
  zshrc-prepend ? "",
  zshrc-append ? "",
}: let
  zsh-syntax-highlighting = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
  zsh-autosuggestions = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh";
  zshrc-prepend-file = pkgs.writeText ".zshrc_prepend" zshrc-prepend;
  zshrc-append-file = pkgs.writeText ".zshrc_append" zshrc-append;
in
  symlinkJoin ({
      paths = [zsh];
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
    // {inherit (zsh) man meta name passthru pname version;})
