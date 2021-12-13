# docker-mpd [![Build Status](https://jenkins.bln.space/buildStatus/icon?job=docker-images%2Fdocker-mpd%2Fmaster)](https://jenkins.bln.space/job/docker-images/job/docker-mpd/job/master/) [![Docker Pulls](https://img.shields.io/docker/pulls/gutmensch/mpd.svg)](https://registry.hub.docker.com/u/gutmensch/mpd/)

mpd - music player daemon

alpine build for home entertainment, alsa only - no pulse, jack, libao, pipewire bloat :P

Goals:

- Use USB optical out device on QNAP in Docker Container

- Support MPC and most other audio formats

- Forget about SMB and NFS (mount in Container anyway)

- Have frontend for mpd deployed as well (s6 + ympd)


## Usage
```
docker run -d --net host --cpus ".5" --memory 256mb --cap-add SYS_NICE -v var-lib-mpd:/var/lib/mpd -v /share/Multimedia/Music:/media/music:ro -v /dev/snd:/dev/snd --name mpd-1 -e MPD_ALSA_NAME="USB Audio" -e MPD_ALSA_DEVICE="iec958:CARD=U0xccd0x77,DEV=0" --restart always gutmensch/mpd:0.23.5
```

## Docker Env Variables (defaults marked bold)
```
MPD_LOG_LEVEL - mpd log level (e.g. **default**, verbose, etc.)
MPD_PORT - mpd server port (**6600**)
MPD_MUSIC_DIRECTORY - music directory (e.g. **/media/music**)
MPD_ALSA_NAME - display name of alsa output device for ympd (**AudioDevice**)
MPD_ALSA_DEVICE - address of alsa output device (**hw:0,0**)
MPD_ALSA_BUFFER_TIME - alsa buffer time increased if you see messages like 'decoder too slow' (**250000**)
MPD_ALSA_PERIOD_TIME - same tuning as above (**5084**)
MPD_HTTPD_OUTPUT_PORT - mpd http streaming port (**8800**)
MPD_HTTPD_OUTPUT_QUALITY - mpd http streaming lame quality (**3.0**)
```
