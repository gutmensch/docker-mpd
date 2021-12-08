#!/usr/bin/env bats

@test "mpd test proper c bindings with linker" {
  result="$(ldd /usr/bin/mpd)"
  [ "$result" -eq 0 ]
}
