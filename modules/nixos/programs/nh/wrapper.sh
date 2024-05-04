function set_colors() {
	COLOR_CYAN='\033[0;35m'
	COLOR_RED='\033[0;31m'
	COLOR_YELLOW='\033[1;33m'
	COLOR_NC='\033[0m'
}
function set_labels() {
	set_colors
	function echo_info() {
		if [ -t 1 ]; then
			echo -e "${COLOR_CYAN}INFO:${COLOR_NC} $@";
		else
			echo -e "INFO: $@";
		fi
	}
	function echo_warn() {
		if [ -t 1 ]; then
			echo -e "${COLOR_YELLOW}WARN:${COLOR_NC} $@";
		else
			echo -e "WARN: $@";
		fi
	}
	function echo_error() {
		if [ -t 1 ]; then
			echo -e "${COLOR_RED}ERRO:${COLOR_NC} $@";
		else
			echo -e "ERRO: $@";
		fi
	}
}
set_labels

function decrypt_lesser_secrets() {
	set -e
	pushd "$FLAKE_DIR" > /dev/null

	for f in ./secrets/*.lesser.*; do
		local filename="$(basename -- "$f")"
		local extension="${filename##*.}"
		local filename="${filename%.*}"
		local subextenstion="${filename##*.}"

		if [[ "$subextenstion" == "decrypted" ]]; then
			echo_warn "$PREFIX - File already decrypted! file=$f"
		else
			echo_info "$PREFIX - Decrypting lesser secret file. file=$f"
			sops --output "./secrets/$filename.decrypted.$extension" -d "$f"
		fi
	done

	echo_info "$PREFIX - Adding decrypted secret files"
	git add ./secrets/*.decrypted.*

	popd > /dev/null
}

function remove_decrypted_secrets() {
	set -e
	pushd "$FLAKE_DIR" > /dev/null

	echo_info "$PREFIX - Removing descrypted files"
	for f in "$FLAKE_DIR"/secrets/*.decrypted.*; do
		echo_info "$PREFIX - Removing descrypted files. file=$f"
		git reset "$f"
		rm "$f"
	done

	popd > /dev/null
}

function format_files() {
	set -e
	pushd "$FLAKE_DIR" > /dev/null

	echo_info "$PREFIX - Formatting *.nix files"
	alejandra . &>/dev/null \
	|| (alejandra . ; \
		echo_error - "$PREFIX - Failed to format files" \
		&& exit 1)

	echo_info "$PREFIX - Formatting *.sh files"
	find "$FLAKE_DIR" -type f -name "*.sh" -execdir shellharden --replace {} \;

	popd > /dev/null
}

function build_os() {
	set -e
	pushd "$FLAKE_DIR" > /dev/null

	echo_info "$PREFIX - Building NixOS"
	nh os switch "$@" "$FLAKE_DIR" \
		|| (echo_error "$PREFIX - Failed to build NixOS" \
		&& remove_decrypted_secrets \
		&& exit 1)

	popd > /dev/null
}

case "$1" in
	"os")
		case "$2" in
			"switch")
				PREFIX="nh os switch"

				decrypt_lesser_secrets
				format_files

				shift 2
				build_os "$@"

				remove_decrypted_secrets
			;;
			*) echo_error "\"$2\" subcommand does not exist"
			;;
		esac
	;;
	"edit")
		pushd "$FLAKE_DIR" > /dev/null

		"$EDITOR" .

		popd > /dev/null
	;;
	"sync")
		pushd "$FLAKE_DIR" > /dev/null

		lazygit

		popd > /dev/null
	;;
	"secrets")
		PREFIX="nh secrets"
		case "$2" in
			"-d"|"--decrypt") decrypt_lesser_secrets
			;;
			"-r"|"--remove") remove_decrypted_secrets
			;;
		esac
	;;
	"format")
		pushd "$FLAKE_DIR" > /dev/null

		format_files

		popd > /dev/null
	;;
	"--")
		shift 1
		nh "$@"
	;;
	*) echo_error "\"$1\" command does not exist"
	;;
esac
