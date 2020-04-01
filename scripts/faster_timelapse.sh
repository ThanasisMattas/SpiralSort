#!/bin/bash
# script: faster_timelapse.sh
# ------------------------
# This script uses ffmepg to read an .mp4 timelapse (first encountered) at the
# current directory and creates a new one, that rans faster. It also outputs a
# light gif.
#
# You can pass 1 argument at the range of 0.0 - 1.0, selecting the duration of
# the new video as a portion of the duration of the old video (default: 0.6).
#
# examples:
# $ faster_timelapse
# $ faster_timelapse 0.5

# check if an argument is passed: portion of previous video duration (0.0 - 1.0)
if [ $# -eq 0 ]; then
	# default
	portion=0.6
else
	portion=$1
fi

# get file name
mp4s=( ./*.mp4 )
old_file_name="${mp4s[0]}"

# check if there are any .mp4's
if [ ${mp4s[0]: -5} == "*.mp4" ]; then
    echo "No .mp4's here"
fi

# get file name without extension and its extension
filename="${old_file_name%.*}"
extension="${old_file_name##*.}"

# create new file name
faster="_faster"
new_file_name="$filename$faster.$extension"

# create gif name
gif_name="$filename$faster.gif"

# create faster timelapse with the same quality
ffmpeg -i "$old_file_name" -filter:v "setpts=${portion}*PTS" -q 1 -loglevel panic \
	"$new_file_name"

# create gif
ffmpeg -i "$new_file_name" -vf \
	"scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
	-loop 0 -loglevel panic "$gif_name"
