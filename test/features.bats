#!/usr/bin/env bats

load helper

@test "mpd expected decoder plugins" {
  run check_decoder "[mad]" "mp3 mp2"; [ "$status" -eq 0 ]
  run check_decoder "[mpg123]" "mp3"; [ "$status" -eq 0 ]
  run check_decoder "[flac]" "flac"; [ "$status" -eq 0 ]
  run check_decoder "[opus]" "opus ogg oga"; [ "$status" -eq 0 ]
  run check_decoder "[sndfile]" "wav aiff aif au snd paf iff svx sf voc w64 pvf xi htk caf sd2"; [ "$status" -eq 0 ]
  run check_decoder "[audiofile]" "wav au aiff aif"; [ "$status" -eq 0 ]
  run check_decoder "[faad]" "aac"; [ "$status" -eq 0 ]
  run check_decoder "[mpcdec]" "mpc"; [ "$status" -eq 0 ]
  run check_decoder "[wavpack]" "wv"; [ "$status" -eq 0 ]
  run check_decoder "[wildmidi]" "mid"; [ "$status" -eq 0 ]
  run check_decoder "[ffmpeg]" "aac ac3 adx afc aif aifc aiff al alaw amr anim apc ape asf atrac au aud avi avm2 avs bap bfi c93 cak cin cmv cpk daud dct divx dts dv dvd dxa eac3 film flac flc fli fll flx flv g726 gsm gxf iss m1v m2v m2t m2ts m4a m4b m4v mad mj2 mjpeg mjpg mka mkv mlp mm mmf mov mp+ mp1 mp2 mp3 mp4 mpc mpeg mpg mpga"; [ "$status" -eq 0 ]
}

@test "mpd expected encoder plugins" {
  values="$(mpd -V | grep -A1 'Encoder plugins:' | tail -n 1)"
  expected="null vorbis opus lame twolame wave flac"

  for e in $expected; do
    echo test for $e
    [[ $values =~ $e ]]
  done
}

@test "mpd expected filters" {
  values="$(mpd -V | grep -A1 'Filters:' | tail -n 1)"
  expected="libsamplerate soxr"

  for e in $expected; do
    echo test for $e
    [[ $values =~ $e ]]
  done
}

@test "mpd expected input plugins" {
  values="$(mpd -V | grep -A1 'Input plugins:' | tail -n 1)"
  expected="file alsa archive curl ffmpeg nfs mms"

  for e in $expected; do
    echo test for $e
    [[ $values =~ $e ]]
  done
}

@test "mpd expected output plugins" {
  values="$(mpd -V | grep -A1 'Output plugins:' | tail -n 1)"
  expected="shout null fifo sndio alsa oss httpd recorder"

  for e in $expected; do
    echo test for $e
    [[ $values =~ $e ]]
  done
}

@test "mpd expected playlist plugins" {
  values="$(mpd -V | grep -A1 'Playlist plugins:' | tail -n 1)"
  expected="extm3u m3u pls soundcloud flac cue embcue"

  for e in $expected; do
    echo test for $e
    [[ $values =~ $e ]]
  done
}

@test "mpd expected protocols" {
  values="$(mpd -V | grep -A1 'Protocols:' | tail -n 1)"
  expected="file:// http:// https:// mms:// mmsh:// mmst:// mmsu:// gopher:// rtp:// rtsp:// rtmp:// rtmpt:// rtmps:// nfs:// alsa://"

  for e in $expected; do
    echo test for $e
    [[ $values =~ $e ]]
  done
}

@test "mpd expected tag plugins" {
  values="$(mpd -V | grep -A1 'Tag plugins:' | tail -n 1)"
  expected="id3tag"

  for e in $expected; do
    echo test for $e
    [[ $values =~ $e ]]
  done
}
