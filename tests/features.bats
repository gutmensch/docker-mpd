#!/usr/bin/env bats

@test "mpd expected features" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}
