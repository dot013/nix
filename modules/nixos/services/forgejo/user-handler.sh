
gum log --structured \
		--time timeonly \
		--level debug \
		'Handling forgejo users'

fjuser list | awk '{print $2}' | tail -n +2 | while read username; do
	if printf '%s\0' "${declared_users[@]}" | grep -Fxqz -- "$username"; then
		gum log --structured \
				--time timeonly \
				--level info \
				'Declared user already exists, ignoring' \
				username "$username"
	else
		if [[ "$(fjuser list | tail -n +2 | awk '{print $2 " " $5}' | grep "$username" | awk '{print $2}')" == "true" ]]; then
			gum log --structured \
					--time timeonly \
					--level warn \
					'Undeclared user is an ADMIN, ignoring' \
					username "$username"
		elif [[ "$handle_undeclared_users" == "true" ]]; then
			gum log --structured \
					--time timeonly \
					--level info \
					'DELETING undeclared user' \
					username "$username"
			fjuser delete -u "$username"
		else
			gum log --structured \
					--time timeonly \
					--level warn \
					'UNDECLARED user, please declare it to have a reproducible build' \
					username "$username"
		fi
	fi
done

# this is used in the string inside ./default.nix
function set-user() {
	local username=$1
	local email=$2
	local password=$3
	local admin=$4

	gum log --structured \
			--time timeonly \
			--level debug \
			'Setting user' \
			username "$username" \
			email "$email"

	if [[ "$(fjuser list | grep "$username" | awk '{print $2}')" ]]; then
		gum log --structured \
				--time timeonly \
				--level error \
				'User with username already exists' \
				username "$username"
	elif [[ "$(fjuser list | grep "$email" | awk '{print $3}')" ]]; then
		gum log --structured \
				--time timeonly \
				--level error \
				'User with username already exists' \
				email "$email"
	else
		if [[ "$admin" == "true" ]]; then
			gum log --structured \
					--time timeonly \
					--level debug \
					'Creating ADMIN user' \
					username "$username" \
					email "$email"

			fjuser create --username "$username" \
						--email "$email" \
						--password "$password" \
						--admin
		else
			gum log --structured \
					--time timeonly \
					--level debug \
					'Creating user' \
					username "$username" \
					email "$email"

			fjuser create --username "$username" \
						--email "$email" \
						--password "$password"
		fi
	fi
}
