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

# Update the Shaka Player repo, and build a commit log in the format Gource
# expects.  (user:<NAME>\n<TIMESTAMP>\n<FORMATTED_LIST_OF_FILES>)

# Clone Shaka if we haven't yet.
mkdir -p tmp
if [ ! -d tmp/shaka-player ]; then
  git clone https://github.com/shaka-project/shaka-player tmp/shaka-player
fi

# Update the source.
git -C tmp/shaka-player pull origin --rebase

# Start with a canned version of the commits as they happened before we started
# pushing every commit to GitHub.  (Pre-v1.1.)
cat sources/pre-release.log > tmp/log.txt

# Append the actual repo history starting at v1.1.
git --git-dir tmp/shaka-player/.git \
    log --pretty=format:user:%aN%n%ct --reverse --raw \
        --encoding=UTF-8 --no-renames \
        v1.1..HEAD >> tmp/log.txt

# Normalize names in the log.
./scripts/rename-aliases.sh tmp/log.txt

# Get a list of release tags, excluding -master and -main tags (not releases),
# in the format Gource expects (timestamp|tag name).  These pop up during the
# stream at the appropriate times to show when releases were made.
git --git-dir tmp/shaka-player/.git \
    log --reverse --tags --simplify-by-decoration --pretty="format:%ct %D" | \
    grep tag: | \
    grep -Ev -- '-(master|main)' | \
    sed -e 's/,.*//' -e 's/ tag: /|/' > tmp/releases.txt
