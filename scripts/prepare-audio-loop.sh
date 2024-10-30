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

# Prepare in advance a single audio file to loop in the output stream.

# Show every command run.
set -x

# Create a quick concatenation of all audio files into one.
mkdir -p tmp
mkdir -p intermediate

# If the file doesn't exist yet, create it.
if [ ! -e intermediate/audio_loop.mp4 ]; then
  # Convert each MP3 to raw PCM audio, then concatenate them all.
  for i in sources/bach/*.mp3; do
    ffmpeg -i $i -f s16le -c:a pcm_s16le -y tmp/audio_temp.raw
    cat tmp/audio_temp.raw >> tmp/audio_loop.raw
  done
  rm -f tmp/audio_temp.raw

  # Note that sending FLAC through Streamer in TS breaks things, so we encode
  # the loop in AAC at 192kbps instead.
  ffmpeg -f s16le -ar 48000 -ac 2 -i tmp/audio_loop.raw \
      -c:a aac -b:a 192k intermediate/audio_loop.mp4
  rm -f tmp/audio_loop.raw
fi

