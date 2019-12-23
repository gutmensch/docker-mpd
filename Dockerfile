FROM alpine:3.10

# copied in most parts from https://github.com/VITIMan/docker-music-stack/blob/master/mpd
# start on qnap with
# docker run -d  --cpus ".2" --memory 256mb --cap-add SYS_NICE --net host -v var-lib-mpd:/var/lib/mpd -v /share/Music:/media/music:ro --device=/dev/snd:/dev/snd --name mpd-1 --restart always gutmensch/mpd:latest
# and enable rt scheduling first on qnap with sysctl -w kernel.sched_rt_runtime_us=-1

LABEL maintainer="@gutmensch https://github.com/gutmensch"

# running as user mpd not possible on qnap because
# /dev/snd rights wrong, audio group missing
RUN apk -q update \
    && apk -q --no-progress add mpd \
    && apk -q --no-progress add mpc \
    && apk -q --no-progress add alsa-utils \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /var/lib/mpd/playlists

VOLUME ["/var/lib/mpd", "/media/music"]

COPY ./manifest/ /

EXPOSE 6600
EXPOSE 8800
EXPOSE 8000

CMD ["mpd", "--stdout", "--no-daemon", "/etc/mpd.conf"]
