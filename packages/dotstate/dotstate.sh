#!/usr/bin/env bash

dotstate() {
	local SOCKET="/tmp/dotstate.sock"

	local cmd="$1"
	shift 1

	case "$cmd" in
	"get")
		if [ ! -f "$SOCKET" ]; then
			echo '{}' | socat - UNIX-LISTEN:"$SOCKET" &
			socat -u UNIX-CONNECT:"$SOCKET" -
		else
			socat -u UNIX-CONNECT:"$SOCKET" -
		fi
		;;
	"set")
		echo "$@" | socat - UNIX-LISTEN:"$SOCKET"
		;;
	*)
		echo "Incorrect command"
		;;
	esac

}

dotstate "$@"
