#!/usr/bin/env bats

load helper

@test "test expected mpd.conf after env parsing - 1" {
  cp /etc/mpd.conf.skel /tmp/mpd.conf.skel-1
  bash -c "MPD_CONF_SKEL=/tmp/mpd.conf.skel-1 \
           MPD_CONF_TARGET=/tmp/mpd.conf.1 \
           MPD_LOG_LEVEL=verbose \
           MPD_PORT=6666 \
           MPD_MUSIC_DIRECTORY=/music \
           MPD_ALSA_NAME=AudioDevice \
           MPD_ALSA_DEVICE=hw:0,0 \
           MPD_ALSA_BUFFER_TIME=1000000 \
           MPD_ALSA_PERIOD_TIME=8000 \
           MPD_HTTPD_OUTPUT_ENCODER=opus \
           MPD_HTTPD_OUTPUT_PORT=8888 \
           MPD_HTTPD_OUTPUT_BITRATE=128000 \
           MPD_RESAMPLER=soxr \
           bash /etc/cont-init.d/01-configure-mpd"
  [ "$(sed '/^$/d' /tmp/mpd.conf.1 | md5sum | awk '{print $1}')" = "2e31932e93689d318f50b7cc292bc70b" ]
}

@test "test expected mpd.conf after env parsing - 2" {
  cp /etc/mpd.conf.skel /tmp/mpd.conf.skel-2
  bash -c "MPD_CONF_SKEL=/tmp/mpd.conf.skel-2 \
           MPD_CONF_TARGET=/tmp/mpd.conf.2 \
           MPD_LOG_LEVEL=default \
           MPD_PORT=6600 \
           MPD_MUSIC_DIRECTORY=/media/music \
           MPD_ALSA_NAME=AudioDevice \
           MPD_ALSA_DEVICE=hw:0,0 \
           MPD_ALSA_BUFFER_TIME=100000 \
           MPD_ALSA_PERIOD_TIME=8000 \
           MPD_HTTPD_OUTPUT_ENCODER=lame \
           MPD_HTTPD_OUTPUT_PORT=9999 \
           MPD_HTTPD_OUTPUT_QUALITY=4.0 \
           MPD_RESAMPLER=libsamplerate \
           bash /etc/cont-init.d/01-configure-mpd"
  [ "$(sed '/^$/d' /tmp/mpd.conf.2 | md5sum | awk '{print $1}')" = "cd5d643a508021f8af5ee70742ceea38" ]
}
