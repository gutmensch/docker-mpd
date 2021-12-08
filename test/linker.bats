#!/usr/bin/env bats

@test "mpd test proper c bindings with linker" {
  ldd /usr/bin/mpd 1>/dev/null
}
