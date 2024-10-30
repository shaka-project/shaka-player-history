#!/bin/bash

# Shaka Player History Live Stream
#
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Run Gource to generate a video stream from Shaka Player's commit history.

# Takes the output pipe as an argument.
OUTPUT="$1"
if [ -z "$OUTPUT" ]; then
  echo "Specify output pipe path." 1>&2
  exit 1
fi

# Run Gource over and over in a loop.  Each loop reads and generates
# visualizations for the entire repo history once.  To keep the pipe from
# getting closed between iterations, each Gource instance writes to its stdout,
# and the loop's stdout is connected to the output pipe.
while true; do
  # Fail on error.
  set -e

  # Update the git history for the Shaka Player repo.
  # Keep all stdout redirected to stderr, to avoid putting garbage in the pipe.
  ./scripts/update-git.sh 1>&2

  # Get the title for the bottom of the frame from this file.
  title="$(cat sources/title.txt)"

  # To deal with overscan on TVs, we output at 1240x680 and pad 20px on all
  # sides later in the Shaka Streamer config (up to 1280x720, standard 720p).
  gource \
    -1240x680 \
    --title "$title" \
    --camera-mode overview \
    --hide bloom,filenames,mouse,progress \
    --highlight-users \
    --auto-skip-seconds 1 \
    --output-framerate 30 \
    --file-filter third_party \
    --file-filter closure \
    --file-filter jasmine \
    --file-filter tutorials/porting.html \
    --file-filter '^\.' \
    --max-file-lag 0.1 \
    --max-user-speed 200 \
    --seconds-per-day 0.5 \
    --highlight-dirs \
    --date-format "%Y-%m-%d" \
    --hash-seed 8675309 \
    --loop-delay-seconds 10 \
    --disable-input \
    --user-image-dir sources/user-images/ \
    --path tmp/log.txt \
    --caption-file tmp/releases.txt \
    --caption-size 24 \
    --caption-duration 6 \
    --caption-offset 70 \
    -o -
done > "$OUTPUT"
