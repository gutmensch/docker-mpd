# docker-mpd [![Build Status](https://jenkins.bln.space/buildStatus/icon?job=docker-images%2Fdocker-mpd)](https://jenkins.bln.space/job/docker-images/job/docker-mpd/) [![Docker Pulls](https://img.shields.io/docker/pulls/gutmensch/mpd.svg)](https://registry.hub.docker.com/u/gutmensch/mpd/)

mpd - music player daemon

Caution: This is for personal use mostly! 0.21.x is causing buffer underruns in my setup, hence sticking with 0.20.x now.

Goals:

- Use USB optical out device on QNAP in Docker Container

- Support MPC and most other audio formats

- Forget about SMB and NFS (mount in Container anyway)

- Have frontend for mpd deployed as well (s6 + ympd)


## Usage
```
docker pull gutmensch/mpd
docker run -d --net host --cpus ".1" --memory 256mb -v var-lib-mpd:/var/lib/mpd -v /share/Multimedia/Music:/media/music:ro -v /dev/snd:/dev/snd --privileged --name mpd-1 --restart always gutmensch/mpd
```
