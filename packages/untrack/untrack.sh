function rand_hex() {
	local length="$1"

	cat /dev/urandom | tr -cd 'a-f0-9' | head -c "$length"
}

# TODO: Support for directories
function untrack() {
	local file="$1"

	local filename="$(basename "$file")"
	local ext="${filename##*.}"
	local directory="$(dirname "$file")"

	local output_file="$directory/$(rand_hex 6).$ext"

	cp "$file" "$output_file"

	exiftool \
		-overwrite_original \
		-all= \
		"$output_file"
}

untrack "$1"
