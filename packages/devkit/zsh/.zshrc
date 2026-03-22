# Source OS-specific configurations
if [ -f "$HOME/.zshrc" ]; then
	source "$HOME/.zshrc"
fi

#@zshrc-prepend@

typeset -U auto cdpath fpath manpath

if [ -f "$ZSHRC_PREPEND" ]; then
	source "$ZSHRC_PREPEND"
fi

# Autocompletion
autoload -U compinit && compinit

#@zsh-plugin-autosuggestions@

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
if command -v "starship" >/dev/null 2>&1; then
	if [[ "$TERM" != "dump" ]]; then
		eval "$(starship init zsh)"
	fi
fi

#@zsh-plugin-syntaxhighlighing@

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

if command -v "yazi" >/dev/null 2>&1; then
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
fi

if command -v "nvim" >/dev/null 2>&1; then
	EDITOR="nvim"
elif command -v "vim" >/dev/null 2>&1; then
	EDITOR="vim"
elif command -v "vi" >/dev/null 2>&1; then
	EDITOR="vi"
fi

#@zshrc-append@

if [ -f "$ZSHRC_APPEND" ]; then
	source "$ZSHRC_APPEND"
fi

# Fetch intro
if command -v "fastfetch" >/dev/null 2>&1; then
	if [[ "$TERM" != "dump" ]]; then
		fastfetch
	fi
fi
