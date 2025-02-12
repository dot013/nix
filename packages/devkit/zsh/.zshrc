# Source OS-specific configurations
if [ -f "$HOME/.zshrc" ]; then
	source "$HOME/.zshrc"
fi

typeset -U auto cdpath fpath manpath

if [ -f "$ZSHRC_PREPEND" ]; then
	source "$ZSHRC_PREPEND"
fi

# Autocompletion
autoload -U compinit && compinit

# Autosuggestion
source "$ZSH_PLUGIN_AUTOSUGGESTIONS"
ZSH_AUTOSUGGEST_STRATEGY=(history)

# Command history
HISTSIZE=1000
SAVEHIST=1000

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname $HISTFILE)"

setopt HIST_FCNTL_LOCK
unsetopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
unsetopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
unsetopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY

# Start starship for interactive shells
if [[ "$TERM" != "dump" ]]; then
	eval "$(starship init zsh)"
fi

# Syntax highlighting
source "$ZSH_PLUGIN_SYNTAXHIGHLIGHING"
ZSH_HIGHLIGHT_HIGHLIGHTERS+=()

# Integration for Zellij
if command -v "zellij" >/dev/null 2>&1; then
	eval "$(zellij setup --generate-auto-start zsh)"
fi

# Integration for direnv
if command -v "direnv" >/dev/null 2>&1; then
	eval "$(direnv hook zsh)"
fi

# Integration for Ghostty
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
	source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

# Integration with GPG
export GPG_TTY="$TTY"

# Aliases
alias -- vi='nvim'
alias -- vim='nvim'
alias -- vimdiff='nvim -d'
alias -- lg='lazygit'

# Yazi alias (with wrapper to change cwd)
function y() {
	local tmp="$(mktemp -t "yazi-cmd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
# Yazi alias (without wrapper to change cwd)
alias -- yy='yazi'

if [ -f "$ZSHRC_APPEND" ]; then
	source "$ZSHRC_APPEND"
fi
