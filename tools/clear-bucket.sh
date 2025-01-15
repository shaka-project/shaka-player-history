#!/bin/bash

# Shaka Player History Live Stream
#
# Copyright 2025 Google LLC
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

set -e
set -x

# Clear the bucket.  Use between stopping and starting the service if you want
# to wipe out the old content.
gsutil -m rm -r gs://shaka-live-assets/player-source/
gsutil -m rm -r gs://shaka-live-assets/player-source.*
