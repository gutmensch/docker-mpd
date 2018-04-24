# docker-mpd [![Docker Pulls](https://img.shields.io/docker/pulls/gutmensch/mpd.svg)](https://registry.hub.docker.com/u/gutmensch/mpd/)

mpd - music player daemon

## Usage
```
docker pull gutmensch/mpd
docker run -d --net host --cpus ".1" --memory 256mb -v var-lib-mpd:/var/lib/mpd -v /share/Multimedia/Music:/media/music:ro -v /dev/snd:/dev/snd --privileged --name mpd-1 --restart always gutmensch/mpd
```

