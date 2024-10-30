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

# Main script to launch Shaka Streamer and generate a live stream based on
# Shaka Player's commit history.  Output goes directly to Google Cloud Storage.

# Fail on error.
set -e

# Show every command run.
set -x

# NOTE: Run this inside xvfb-run -a if you aren't in an X11 session.
if [ -z "$DISPLAY" ]; then
  echo "X11 display or Xvfb required!" 1>&2
  exit 1
fi

# Go to this directory.
cd $(dirname "$0")

# Generate the audio loop if you haven't yet.
./scripts/prepare-audio-loop.sh

# Just in case, because we've had issues in the past, kill any running
# instances of Gource that didn't shut down properly.
killall -9 gource &>/dev/null || true

# Use local Shaka Streamer source if present, but fall back to a global install
# of Shaka Streamer otherwise.
if [ -e ./shaka-streamer ]; then
  streamer_binary=./shaka-streamer/shaka-streamer
else
  streamer_binary=shaka-streamer
fi

# Run Shaka Streamer and output to cloud storage.
$streamer_binary \
  -i config/input.yaml \
  -p config/pipeline.yaml \
  -c gs://shaka-live-assets/
