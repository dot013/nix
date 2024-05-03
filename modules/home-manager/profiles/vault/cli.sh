set -e

function sync() {
	pushd "$VAULT_DIR"

	git pull

	git add .

	if [[ $(git status --porcelain) ]]; then
		git commit -am "vault sync: $(date +%F) $(date +%R)"
		git push -u origin main
	fi

	popd
}


case "$1" in
	"sync") sync ;;
	*) echo "Not a valid command: $1" ;;
esac
