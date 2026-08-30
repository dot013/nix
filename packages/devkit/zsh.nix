{
  lib,
  linkFarm,
  wrapPackage,
  writeTextFile,
  pkgs,
  stdenv,
  # Package
  zsh ? pkgs.zsh,
  # Plugins
  fzf-zsh-plugin ? pkgs.fzf-zsh-plugin,
  nix-zsh-completions ? pkgs.nix-zsh-completions,
  zsh-autosuggestions ? pkgs.zsh-autosuggestions,
  zsh-completions ? pkgs.zsh-completions,
  zsh-fzf-tab ? pkgs.zsh-fzf-tab,
  zsh-syntax-highlighting ? pkgs.zsh-syntax-highlighting,
  # Runtime Inputs
  git ? pkgs.git,
  fzf ? pkgs.fzf,
  lazygit ? pkgs.lazygit,
  neovim ? pkgs.neovim,
  starship ? pkgs.starship,
  yazi ? pkgs.yazi,
}:
with lib;
  wrapPackage rec {
    inherit pkgs;
    package = zsh;

    runtimeInputs = [
      starship
      nix-zsh-completions
      zsh-completions

      git
      fzf
      lazygit
      neovim
      yazi
    ];

    env.ZDOTDOTDIR = env.ZDOTDIR;
    env.ZDOTDIR = toString (linkFarm "zsh-config" [
      {
        name = ".zshrc";
        path = writeTextFile {
          name = ".zshrc";
          text = ''
            bindkey -v # vicmd

            setopt autocd

            # Completion
            autoload -U compinit && compinit
            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
            zstyle ':completion:*' menu no
            source ${zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
            source ${fzf-zsh-plugin}/share/zsh/fzf-zsh-plugin/fzf-zsh-plugin.plugin.zsh

            # Auto Suggestions
            source "${zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh";
            ZSH_AUTOSUGGEST_STRATEGY=("history" "completion")

            # Syntax Highlighting
            source "${zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
            ZSH_HIGHLIGHT_HIGHLIGHTERS+=("brackets")

            # Integrations
            source <(${getExe fzf} --zsh)
            if [[ $TERM != "dumb" ]]; then
              eval "$(${getExe starship} init zsh)"
            fi
            if command -v "zellij" >/dev/null 2>&1; then
              eval "$(zellij setup --generate-auto-start zsh)"
            fi
            if command -v "direnv" >/dev/null 2>&1; then
              eval "$(direnv hook zsh)"
            fi
            if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
            	source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
            fi

            EDITOR="${getExe neovim}"
            alias -- vi='${getExe neovim}'
            alias -- vim='${getExe neovim}'
            alias -- vimdiff='${getExe neovim} -d'

            function y() {
              local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
              command yazi "$@" --cwd-file="$tmp"
              if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                builtin cd -- "$cwd"
              fi
              rm -f -- "$tmp"
            }

            function lg() {
                export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir
                command lazygit "$@"
                if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
                  cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
                  rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
                fi
            }

            export GPG_TTY="$TTY"

            # History
            HISTSIZE=1000
            SAVEHIST=1000

            HISTFILE=''${XDG_CONFIG_HOME:-"''${HOME:-"~"}/.config"}/zsh/.zsh_history
            mkdir -p "$(dirname $HISTFILE)"

            setopt appendhistory
            setopt sharehistory

            # Start zellij if not inside one
            if [[ $TERM != "dumb" && $ZELLIJ_SESSION_NAME == "" && $DOT_ZSH_INITIALIZED == "" ]]; then
              if [ ! -n "$ZELLIJ" ]; then
                DOT_ZSH_INITIALIZED=1
                zellij
              fi
            fi
          '';
          checkPhase = ''${stdenv.shellDryRun} "$target"'';
        };
      }
      {
        name = ".zshenv";
        path = writeTextFile {
          name = ".zshenv";
          text = ''
            # Source any OS-specific environment variables
            if [ -f "$XDG_CONFIG_HOME/zsh/.zshenv" ]; then
            	source "$XDG_CONFIG_HOME/zsh/.zshenv"
            elif [ -f "$HOME/.config/zsh/.zshenv" ]; then
            	source "$HOME/.config/zsh/.zshenv"
            elif [ -f "$HOME/.zshenv" ]; then
            	source "$HOME/.zshenv"
            fi

            export EDITOR="${getExe neovim}"
            ZDOTDIR="$ZDOTDOTDIR"
            export ZDOTDIR="$ZDOTDOTDIR"
          '';
          checkPhase = ''${stdenv.shellDryRun} "$target"'';
        };
      }
    ]);
    flags = {
      "--histfcntllock" = true;
      "--histexpiredupsfirst" = true;
    };
  }
