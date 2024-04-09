
function nih-edit() {
	local flake_dir="$1"
	local host="$2"

	# Exit if a command exits with a non-zero value
	set -e

	# Push directory to history
	pushd $flake_dir

	# Edit file
	$EDITOR "$(gum file "$flakedir")"

	# Skip if there's no changes
	if git diff --quiet "*.*"; then
		gum log --structured \
			--prefix 'nih edit' \
			--level warn \
			'No files changed'
		popd
		exit 0
	fi

	# Autoformat nix files
	gum log --structured --prefix 'nih edit' --level debug 'Formatting files'
	alejandra . &>/dev/null \
	|| (alejandra . ; \
		gum log --structured \
				--prefix 'nih edit' \
				--level error 'Failed to format files' \
		&& exit 1)

	# Show modifications
	gum log --structured --prefix 'nih edit' --level debug 'Creatting diff files'
	temp_file="$(mktemp /tmp/nih-diff-XXXXX)"
	git diff -U0 '*.nix' > $temp_file
	echo "$(gum format -l diff -t code < $temp_file)" > $temp_file
	gum pager < $temp_file
	rm $temp_file

	# Add secret files
	gum log --structured --prefix 'nih edit' --level debug 'Adding decrypted secret files'
	git add ./secrets/*

	# Build NixOS
	gum log --structured --prefix 'nih edit' --level debug 'Building NixOS'
	sudo nixos-rebuild switch --flake "$flake_dir#$host" \
		|| (gum log --structured --prefix 'nih edit' --level debug 'Removing decrypted secret files' \
		&& git reset ./secrets/*.decrypted.* \
		&& gum log --structured --prefix 'nih edit' --level error 'Error building new config' \
		&& exit 1)

	gum log --structured --prefix 'nih edit' --level debug 'Removing decrypted secret files'
	git reset ./secrets/*

	gum log --structured \
			--prefix 'nih edit' \
			--level info 'NixOS finished building, please commit the changes'
	notify-send -e "NixOS finished building, please commit the changes" \
		--icon=software-update-available \
		--urgency=normal

	case "$(gum choose --limit 1 'Commit' 'Open lazygit' 'No commit')" in
		"Commit")
			commit_msg="$(gum write --prompt 'Commit message' --placeholder 'Commit message')"
			git commit -am "$commit_msg"

			gum confirm 'Push changes to remote?' \
				&& git push \
				|| echo "";
			;;
		"Open lazygit")
			lazygit

			gum confirm 'Push changes to remote?' \
				&& git push \
				|| echo "";
			;;
		*)
			gum log --structured \
				--prefix 'nih edit' \
				--level info 'Not commiting'
			;;
	esac

	gum log --structured --prefix 'nih edit' --level info 'NixOS rebuilt!'
	notify-send -e "NixOS Rebuilt!" \
		--icon=software-update-available \
		--urgency=low

	# Pop back to previous directory
	popd
}

function nih-switch () {
	local flake_dir="$1"
	local host="$2"

	set -e

	pushd $flake_dir

	gum log --structured --prefix 'nih switch' --level debug 'Adding decrypted secret files'
	git add ./secrets/*.decrypted.*

	gum log --structured --prefix 'nih switch' --level debug 'Formatting files'
	alejandra . &>/dev/null \
	|| (alejandra . ; \
		gum log --structured \
				--prefix 'nih switch' \
				--level error 'Failed to format files' \
		&& exit 1)

	gum log --structured --prefix 'nih switch' --level debug 'Building NixOS'
	sudo nixos-rebuild switch --flake "$flake_dir#$host" \
		|| (gum log --structured --prefix 'nih edit' --level debug 'Removing decrypted secret files' \
		&& git reset ./secrets/*.decrypted.* \
		&& gum log --structured --prefix 'nih edit' --level error 'Error building new config' \
		&& exit 1)

	gum log --structured --prefix 'nih switch' --level info 'NixOS rebuilt!'
	notify-send -e "NixOS Rebuilt!" \
		--icon=software-update-available \
		--urgency=low

	gum log --structured --prefix 'nih switch' --level debug 'Removing decrypted secret files'
	git reset ./secrets/*.decrypted.*

	popd
}

function nih-install() {
	local pkgs=()
	local index=0
	for arg in "$@"; do
		if [[ "$arg" == "--" ]]; then
			index=$(($index + 1))
			break
		fi
		pkgs+=("nixpkgs#$arg")
		index=$(($index + 1))
	done
	shift $index
	nix shell "${pkgs[@]}" "$@"
}

function nih-execute() {
	local pkg="$1"
	shift 1
	nix run "nixpkgs#$pkg" "$@"
}

case "$1" in
	"edit") nih-edit $flake_dir $host ;;
	"switch" | "build") nih-switch $flake_dir $host ;;
	"install" | "i" ) shift 1; nih-install "$@" ;;
	"exec" | "x" ) shift 1; nih-execute "$@" ;;
	*) gum log --structured --prefix 'nih' --level error "Command $1 does not exist" ;;
esac

