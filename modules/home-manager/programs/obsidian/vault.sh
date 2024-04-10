
function vault-sync() {
	local vault_dir="$1"

	date="$(date +%F) $(date +%R)"

	set -e

	pushd "$vault_dir"

	gum log --structured --prefix 'vault sync' --level info "Syncing vault through git"

	gum log --structured --prefix 'vault sync' --level debug "Pulling from remote"
	git pull

	# Skip if there's no changes
	if git diff --quiet "*.*"; then
		gum log --structured \
			--prefix 'vault sync' \
			--level warn \
			'No files changed'
		popd
		exit 0
	else
		gum log --structured --prefix 'vault sync' --level debug 'Committing' commit_msg "vault sync: $date"
		git commit -am "vault sync: $date"

		gum log --structured --prefix 'vault sync' --level debug 'Pushing to remote'
		git push

		gum log --structured --prefix 'vault sync' --level info 'Vault synced!'
	fi

	popd
}

case "$1" in
	"sync") vault-sync "$vault_dir" ;;
	*) gum log --structured --prefix 'vault' --level error "Command $1 does not exist" ;;
esac

