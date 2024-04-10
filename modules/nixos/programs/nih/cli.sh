
function util-show-diff() {
	local prefix="$1";

	gum log --structured --prefix "$prefix" --level debug 'Creatting diff files'
	temp_file="$(mktemp /tmp/nih-diff-XXXXX)"
	git diff -U0 '*.*' > $temp_file
	echo "$(gum format -l diff -t code < $temp_file)" > $temp_file
	gum pager < $temp_file
	rm $temp_file
}

function util-build() {
	local prefix="$1";
	local flake_dir="$2";
	local host="$3";

	set -e

	pushd $flake_dir > /dev/null

	for f in ./secrets/*.lesser.*; do
		local filename="$(basename -- "$f")"
		local extension="${filename##*.}"
		local filename="${filename%.*}"
		local subextenstion="${filename##*.}"

		if [[ "$subextenstion" == "decrypted" ]]; then
			gum log --structured --prefix "$prefix" --level warn 'File already decrypted!' file "$f"
		else
			gum log --structured --prefix "$prefix" --level debug 'Decrypting lesser secret file' file "$f"
			sops --output "./secrets/$filename.decrypted.$extension" -d $f
		fi
	done

	# Add secret files
	gum log --structured --prefix "$prefix" --level debug 'Adding decrypted secret files'
	git add ./secrets/*.decrypted.*

	# Build NixOS
	gum log --structured --prefix "$prefix" --level debug 'Building NixOS'
	sudo nixos-rebuild switch --flake "$flake_dir#$host" \
		|| (gum log --structured --prefix "$prefix" --level debug 'Removing decrypted secret files' \
		&& git reset ./secrets/*.decrypted.* \
		&& for f in ./secrets/*.decrypted.*; do rm $f; done \
		&& gum log --structured --prefix "$prefix" --level error 'Error building new config' \
		&& exit 1)

	git reset ./secrets/*.decrypted.*
	for f in ./secrets/*.decrypted.*; do
		gum log --structured --prefix "$prefix" --level debug 'Removing decrypted secret file' file "$f"
		rm $f
	done

	popd > /dev/null
}

function util-format() {
	local prefix="$1"
	local flake_dir="$2"

	pushd $flake_dir > /dev/null

	gum log --structured --prefix "$prefix" --level debug 'Formatting files'
	alejandra . &>/dev/null \
	|| (alejandra . ; \
		gum log --structured \
				--prefix "$prefix" \
				--level error 'Failed to format files' \
		&& exit 1)

	popd > /dev/null
}

function nih-edit() {
	local flake_dir="$1"
	local host="$2"

	# Exit if a command exits with a non-zero value
	set -e

	# Push directory to history
	pushd $flake_dir > /dev/null

	# Edit file
	$EDITOR "$(gum file "$flake_dir")"

	# Skip if there's no changes
	if git diff --quiet "*.*"; then
		gum log --structured \
			--prefix 'nih edit' \
			--level warn \
			'No files changed'
		popd > /dev/null
		exit 0
	fi

	util-format 'nih edit' $flake_dir

	# Show modifications
	util-show-diff 'nih edit'

	# Build nixos
	util-build 'nih edit' $flake_dir $host

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
	popd > /dev/null
}

function nih-switch () {
	local flake_dir="$1"
	local host="$2"

	set -e

	pushd $flake_dir > /dev/null

	gum log --structured --prefix 'nih switch' --level info 'Switching NixOS config'

	util-format 'nih switch' $flake_dir

	# Build nixos
	util-build 'nih switch' $flake_dir $host

	gum log --structured --prefix 'nih switch' --level info 'NixOS rebuilt!'
	notify-send -e "NixOS Rebuilt!" \
		--icon=software-update-available \
		--urgency=low

	popd > /dev/null
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

	gum log --structured --prefix 'nih install' --level info "Temporaly installing to current shell:"
	gum log --structured --prefix 'nih install' --level info "${pkgs[@]}"

	nix shell "${pkgs[@]}" "$@"

	gum log --structured --prefix 'nih install' --level info "Packages intalled!"
}

function nih-execute() {
	local pkg="$1"
	shift 1
	nix run "nixpkgs#$pkg" "$@"
}

function nih-sync() {
	local flake_dir="$1"
	local host="$2"

	set -e

	pushd $flake_dir

	gum log --structured --prefix 'nih sync' --level info 'Syncing NixOS config'

	util-format 'nih sync' $flake_dir

	git reset ./secrets/*.decrypted.*
	for f in ./secrets/*.decrypted.*; do
		gum log --structured --prefix "$prefix" --level debug 'Removing decrypted secret file' file "$f"
		rm $f
	done

	# Skip if there's no changes
	if git diff --quiet "*.*"; then
		gum log --structured \
			--prefix 'nih sync' \
			--level warn \
			'No files changed'
		popd
		exit 0
	else
		# Show modifications
		util-show-diff 'nih sync'

		commit_msg="$(gum write --prompt 'Commit message' --placeholder 'Commit message')"
		git commit -am "$commit_msg"

		gum log --structured --prefix 'nih sync' --level debug 'Pushing to remote'
		git push

		gum log --structured --prefix 'nih sync' --level info 'NixOS configuration synced!'
	fi

	popd
}

case "$1" in
	"edit") nih-edit $flake_dir $host ;;
	"switch" | "build") nih-switch $flake_dir $host ;;
	"install" | "i" ) shift 1; nih-install "$@" ;;
	"exec" | "x" ) shift 1; nih-execute "$@" ;;
	"sync") nih-sync $flake_dir $host ;;
	*) gum log --structured --prefix 'nih' --level error "Command $1 does not exist" ;;
esac
