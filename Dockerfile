ARG ALPINE_VERSION=3.15
FROM alpine:$ALPINE_VERSION AS builder

ARG MPD_VERSION=0.22.11
ARG WILDMIDI_VERSION=0.4.4
ARG CHROMAPRINT_VERSION=1.5.0
ARG OPUS_VERSION=1.3.1
ARG OPUSENC_VERSION=0.2.1
ARG TWOLAME_VERSION=0.4.0
ARG AUDIOFILE_VERSION=0.3.6
ARG MPC_VERSION=0.1~r495-1

RUN apk update \
  && apk add \
	alpine-sdk \
	boost-dev \
	autoconf \
	automake \
	libtool \
        meson \
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
	yajl-dev \
	libshout-dev \
	pcre-dev \
	zziplib-dev \
	libgcrypt-dev \
	libmms-dev \
	icu-dev \
	libnfs-dev \
	xz \
	wget

ADD https://github.com/tatsuz/musepack/archive/master.zip /
RUN cd / \
  && unzip master.zip \
  && rm -f master.zip \
  && cd musepack-master \
  && wget "http://deb.debian.org/debian/pool/main/libm/libmpc/libmpc_${MPC_VERSION}.debian.tar.xz" \
  && tar xvf "libmpc_${MPC_VERSION}.debian.tar.xz" \
  && for i in $(cat debian/patches/series); do echo $i; patch -p1 < debian/patches/$i; done \
  && libtoolize --force \
  && aclocal \
  && autoheader \
  && automake --force-missing --add-missing \
  && autoconf \
  && ./configure --prefix=/usr \
  && make DESTDIR=/build install \
  && cp -av /build/* /

ADD https://github.com/Mindwerks/wildmidi/archive/wildmidi-${WILDMIDI_VERSION}.tar.gz /
RUN tar xzf /wildmidi-${WILDMIDI_VERSION}.tar.gz -C / \
  && cd /wildmidi-wildmidi-${WILDMIDI_VERSION} \
  && libtoolize --force \
  && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TOOLS=ON . \
  && make DESTDIR=/build install \
  && cp -av /build/* /

ADD https://github.com/acoustid/chromaprint/releases/download/v${CHROMAPRINT_VERSION}/chromaprint-${CHROMAPRINT_VERSION}.tar.gz /
RUN tar xzf /chromaprint-${CHROMAPRINT_VERSION}.tar.gz -C / \
  && cd /chromaprint-v${CHROMAPRINT_VERSION} \
  && libtoolize --force \
  && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TOOLS=ON . \
  && make DESTDIR=/build install \
  && cp -av /build/* /

ADD https://archive.mozilla.org/pub/opus/opus-${OPUS_VERSION}.tar.gz /
RUN tar xzf /opus-${OPUS_VERSION}.tar.gz -C / \
  && cd /opus-${OPUS_VERSION} \
  && ./configure --prefix=/usr --disable-static --disable-doc --disable-extra-programs --enable-custom-modes \
  && make DESTDIR=/build install \
  && cp -av /build/* /

ADD https://archive.mozilla.org/pub/opus/libopusenc-${OPUSENC_VERSION}.tar.gz /
RUN tar xzf /libopusenc-${OPUSENC_VERSION}.tar.gz -C / \
  && cd /libopusenc-${OPUSENC_VERSION} \
  && ./configure --prefix=/usr --disable-static --disable-doc --disable-examples \
  && make DESTDIR=/build install \
  && cp -av /build/* /

RUN wget http://downloads.sourceforge.net/twolame/twolame-${TWOLAME_VERSION}.tar.gz -O /twolame-${TWOLAME_VERSION}.tar.gz \
  && tar xzf /twolame-${TWOLAME_VERSION}.tar.gz -C / \
  && cd /twolame-${TWOLAME_VERSION} \
  && ./configure --prefix=/usr --disable-static \
  && make DESTDIR=/build install \
  && cp -av /build/* /

ADD https://audiofile.68k.org/audiofile-${AUDIOFILE_VERSION}.tar.gz /
ENV CXXFLAGS=-fpermissive
RUN tar xzf /audiofile-${AUDIOFILE_VERSION}.tar.gz -C / \
  && cd /audiofile-${AUDIOFILE_VERSION} \
  && ./configure --prefix=/usr --disable-docs --disable-examples --disable-static \
  && make DESTDIR=/build install \
  && cp -av /build/* /

ADD https://github.com/MusicPlayerDaemon/MPD/archive/v${MPD_VERSION}.tar.gz /
ENV DESTDIR=/build
RUN tar xzf /v${MPD_VERSION}.tar.gz -C / \
  && cd /MPD-${MPD_VERSION} \
  && bash -c '[ -f autogen.sh ] && ./autogen.sh || true' \
  && bash -c '[ -f configure ] && ./configure --enable-dsd --prefix=/usr --sysconfdir=/etc --localstatedir=/var --runstatedir=/run && make DESTDIR=/build install || true' \
  && bash -c '[ -f meson.build ] && meson --prefix=/usr --sysconfdir=/etc --localstatedir=/var build && cd build && ninja && ninja install || true' \
  && mkdir -p /build/var/lib/mpd/playlists

ARG ALPINE_VERSION
FROM alpine:$ALPINE_VERSION AS runner

ARG S6_OVERLAY_VERSION=v2.2.0.3

# copied in most parts from https://github.com/VITIMan/docker-music-stack/blob/master/mpd
# start on qnap with
# docker run -d  --cpus ".2" --memory 256mb --cap-add SYS_NICE --net host -v var-lib-mpd:/var/lib/mpd -v /share/Music:/media/music:ro --device=/dev/snd:/dev/snd --name mpd-1 --restart always gutmensch/mpd:latest
# and enable rt scheduling first on qnap with sysctl -w kernel.sched_rt_runtime_us=-1

LABEL maintainer="@gutmensch https://github.com/gutmensch"

# install s6 for mpd and ympd
ADD "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz" /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
  && rm /tmp/s6-overlay-amd64.tar.gz

COPY --from=builder /build/ /

RUN adduser -D -g '' ympd

# running as user mpd not possible on qnap because
# /dev/snd rights wrong, audio group missing
RUN apk -q update \
    && apk -q --no-progress add \
        bats \
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
	pcre \
	sqlite-libs \
	libmodplug \
	zziplib \
	libgcrypt \
	libmms \
	icu-libs \
	libnfs \
	libcdio \
	ympd \
	mpc \
	alsa-utils \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /var/lib/mpd/playlists

VOLUME ["/var/lib/mpd", "/media/music"]

COPY ./manifest/ /
COPY ./test/ /usr/build/test

EXPOSE 6600
EXPOSE 8800
EXPOSE 8000
EXPOSE 8866

ENTRYPOINT ["/init"]
