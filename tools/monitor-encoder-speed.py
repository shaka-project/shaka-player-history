#!/usr/bin/env python3

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

"""Monitor shaka-player-history encoder speed and other events."""

import argparse
import json
import re
import select
import systemd.journal


UNIT_NAME = 'shaka-player-history.service'


def main():
  parser = argparse.ArgumentParser(
      description=__doc__,
      formatter_class=argparse.ArgumentDefaultsHelpFormatter)
  parser.add_argument('-n', '--number', type=int,
          default=100,
          help='How many recent logs to show (0 == all)')
  parser.add_argument('--follow', '-f', action='store_true', default=False,
          help='Show the most recent logs, then wait for new logs.')
  args = parser.parse_args()

  j = systemd.journal.Reader()
  j.add_match(_SYSTEMD_UNIT=UNIT_NAME)
  j.add_disjunction()
  j.add_match(UNIT=UNIT_NAME)

  # Seek to |number| before the end, with respect to our filters.  This happens
  # iteratively so we can run our filters on each entry.
  j.seek_tail()
  seeked = 0
  while seeked <= args.number:
    raw_log = j.get_previous()
    if parse_log(raw_log) is not None:
      seeked += 1

  flush_logs(j)

  # If we're following, we use select.poll to wait for new events.
  if args.follow:
    p = select.poll()
    p.register(j, j.get_events())

    try:
      while True:
        p.poll()
        flush_logs(j)
    except KeyboardInterrupt:
      pass


def flush_logs(j):
  for raw_log in j:
    log = parse_log(raw_log)
    if log:
      log['TS'] = format_timestamp(log['TS'])
      print(log)


def format_timestamp(ts):
  return ts.isoformat()


def parse_log(log):
  if log.get('UNIT') == UNIT_NAME:
    # This is init logging about our service.
    parsed = parse_init_log(log)
  else:
    # This is a log from our service itself.
    parsed = parse_unit_log(log)

  # Could be None to indicate a log we're skipping.
  if parsed:
    return parsed


def parse_init_log(log):
  if 'JOB_TYPE' in log:
    return {
      'TS': log['__REALTIME_TIMESTAMP'],
      'JOB_TYPE': log['JOB_TYPE'],
      'MESSAGE': log['MESSAGE'],
    }
  return None


def parse_unit_log(log):
  parsed = {
    'TS': log['__REALTIME_TIMESTAMP'],
  }

  message = log['MESSAGE']
  # Using .* to match the last possible instance in the line
  match_speed = re.search(r'.*speed=\s*([0-9.]+)x', message)
  match_configs = re.search(r'Configs: (.*)', message)

  if match_speed:
    speed = float(match_speed.group(1))
    parsed['SPEED'] = speed
  elif match_configs:
    parsed['CONFIGS'] = json.loads(match_configs.group(1))
  elif 'Fast-forward' in message:
    parsed['LOOP'] = True
    parsed['NEW_COMMITS'] = True
  elif 'Already up to date' in message:
    parsed['LOOP'] = True
    parsed['NEW_COMMITS'] = False
  else:
    return None

  return parsed


if __name__ == '__main__':
  main()
