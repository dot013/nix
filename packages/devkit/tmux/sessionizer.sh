# "Chat is MIT"
# https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer

SEARCH_PATHS=("$HOME/.projects" "$HOME/.job" "$HOME/.work")

function tmux_sessionizer() {
	local paths=()

	for p in "${SEARCH_PATHS[@]}"; do
		if [ -d "$p" ]; then
			paths+=("$p")
		fi
	done

	if [[ $# -eq 1 ]]; then
		selected="$1"
	else
		selected="$(find "${paths[@]}" -mindepth 1 -maxdepth 1 -type d | fzf)"]
	fi

	if [[ -z "$selected" ]]; then
		exit 0
	fi

	local selected_name="$(basename "$selected" | tr . _)"
	local tmux_running="$(pgrep tmux)"

	if [[ -z "$TMUX" ]] && [[ -z "$tmux_running" ]]; then
		tmux new-session -s "$selected_name" -c "$selected"
		exit 0
	fi

	if ! tmux has-session -t="$selected_name" 2>/dev/null; then
		tmux new-session -ds "$selected_name" -c "$selected"
	fi

	tmux switch-client -t "$selected_name"
}

tmux_sessionizer "$@"
