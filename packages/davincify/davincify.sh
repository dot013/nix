function davincify() {
	local file="$1"
	local filename="${file%.*}"

	ffmpeg \
		-i "$file" \
		-c:v dnxhd \
		-profile:v dnxhr_hq \
		-c:a pcm_s16le \
		-pix_fmt yuv422p \
		"$filename.mov"
}

davincify "$1"
