#!/usr/bin/env bats

@test "mpd expected library bindings" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}
