FROM alpine:3.11 AS builder

ARG AUDIOFILE_VERSION=0.3.6
ARG MPD_VERSION=0.20.23

RUN apk update \
  && apk add \
	alpine-sdk \
	boost-dev \
	autoconf \
	automake \
	libtool \
	libmpdclient-dev \
	libvorbis-dev \
	libsamplerate-dev \
	libid3tag-dev \
	mpg123-dev \
	flac-dev \
	ffmpeg-dev \
	alsa-lib-dev \
	sqlite-dev \
	libmad-dev \
	lame-dev \
	libsndfile-dev \
	faac-dev \
	faad2-dev \
	soxr-dev \
	libcdio-dev \
	bzip2-dev \
	curl-dev \
	wavpack-dev \
	sndio-dev \
	libmodplug-dev \
	libcdio-paranoia-dev \
	yajl-dev \
	libshout-dev

ADD https://audiofile.68k.org/audiofile-${AUDIOFILE_VERSION}.tar.gz /
ENV CXXFLAGS=-fpermissive
RUN tar xzf /audiofile-${AUDIOFILE_VERSION}.tar.gz -C / \
  && cd /audiofile-${AUDIOFILE_VERSION} \
  && ./configure --prefix=/usr --disable-docs --disable-examples --disable-static \
  && make DESTDIR=/build install \
  && cp -av /build/* /

ADD https://github.com/MusicPlayerDaemon/MPD/archive/v${MPD_VERSION}.tar.gz /
RUN tar xzf /v${MPD_VERSION}.tar.gz -C / \
  && cd /MPD-${MPD_VERSION} \
  && sh ./autogen.sh \
  && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --runstatedir=/run \
  && make DESTDIR=/build install \
  && mkdir -p /build/var/lib/mpd/playlists

FROM alpine:3.11 AS runner
# copied in most parts from https://github.com/VITIMan/docker-music-stack/blob/master/mpd
# start on qnap with
# docker run -d  --cpus ".2" --memory 256mb --cap-add SYS_NICE --net host -v var-lib-mpd:/var/lib/mpd -v /share/Music:/media/music:ro --device=/dev/snd:/dev/snd --name mpd-1 --restart always gutmensch/mpd:latest
# and enable rt scheduling first on qnap with sysctl -w kernel.sched_rt_runtime_us=-1

LABEL maintainer="@gutmensch https://github.com/gutmensch"

# install s6 for mpd and ympd
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

COPY --from=builder /build/ /

RUN adduser -D -g '' ympd

# running as user mpd not possible on qnap because
# /dev/snd rights wrong, audio group missing
RUN apk -q update \
    && apk -q --no-progress add \
	libmpdclient \
	flac \
	yajl \
	libsndfile \
	libsamplerate \
	libvorbis \
	faad2-libs \
	sndio-libs \
	libshout \
	mpg123-libs \
	libid3tag \
	libcurl \
	libmad \
	ffmpeg-libs \
	soxr \
	lame \
	wavpack \
	sqlite-libs \
	libcdio \
	libcdio-paranoia \
	libmodplug \
    && apk -q --no-progress add ympd \
    && apk -q --no-progress add mpc \
    && apk -q --no-progress add alsa-utils \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /var/lib/mpd/playlists

VOLUME ["/var/lib/mpd", "/media/music"]

COPY ./manifest/ /

EXPOSE 6600
EXPOSE 8800
EXPOSE 8000
EXPOSE 8866

ENTRYPOINT ["/init"]
