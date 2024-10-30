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

# Normalize the names in the commit history file.  Add to the inline map below
# as needed.

# Takes the log file as an argument.
log="$1"
if [ -z "$log" ]; then
  echo "Specify log file path." 1>&2
  exit 1
fi

# Read fields separated by colons, and use these pairs to modify "$log" in
# place.
IFS=":"; while read alias name; do
  sed -i "$log" -e "s/^user:$alias/user:$name/"
done << EOF
Alvaro Velad:Álvaro Velad Galván
baconz:Seth Madison
bhh1988:Bryan Huh
bjarkler:Bjarki Ágúst Guðmundsson
BucherTomas:Tomas Bucher
Costel G:Costel Madalin Grecu
esteban-dosztal:Esteban Dosztal
iKinnrot:Itay Kinnrot
ismena:Sandra Lokshina
mariocynicys:Omer Yacine
michellezhuo:Michelle Zhuo
Ross-cz:Rostislav Hejduk
swilly22:Roi Lipman
TheJohnBowers:John Bowers
tdrews:Timothy Drews
theodab:Theodore Abshire
github-actions.bot.:Shaka Bot
dependabot.bot.:Shaka Bot
Shaka Player BuildBot:Shaka Bot
EOF
