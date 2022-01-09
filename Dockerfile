ARG ALPINE_VERSION=3.15
FROM alpine:$ALPINE_VERSION AS builder

ARG MPD_VERSION=0.23.5
ARG WILDMIDI_VERSION=0.4.4
ARG CHROMAPRINT_VERSION=1.5.0
ARG OPUS_VERSION=1.3.1
ARG OPUSENC_VERSION=0.2.1
ARG TWOLAME_VERSION=0.4.0
ARG AUDIOFILE_VERSION=0.3.6
ARG MPC_VERSION=0.1~r495-2

WORKDIR /

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
	libupnp-dev \
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
	expat-dev \
	fmt-dev \
	liburing-dev \
	pcre2-dev \
	xz \
	wget

RUN wget https://github.com/tatsuz/musepack/archive/master.zip -O musepack_master.zip \
  && unzip musepack_master.zip \
  && rm -f musepack_master.zip \
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

RUN wget https://github.com/Mindwerks/wildmidi/archive/wildmidi-${WILDMIDI_VERSION}.tar.gz \
  && tar xzf /wildmidi-${WILDMIDI_VERSION}.tar.gz -C / \
  && cd /wildmidi-wildmidi-${WILDMIDI_VERSION} \
  && libtoolize --force \
  && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TOOLS=ON . \
  && make DESTDIR=/build install \
  && mkdir -p /build/etc/wildmidi \
  && mkdir -p /build/usr/share/midi \
  && cp cfg/wildmidi.cfg /build/etc/wildmidi/ \
  && cp -av /build/* /

RUN wget https://github.com/acoustid/chromaprint/releases/download/v${CHROMAPRINT_VERSION}/chromaprint-${CHROMAPRINT_VERSION}.tar.gz \
  && tar xzf /chromaprint-${CHROMAPRINT_VERSION}.tar.gz -C / \
  && cd /chromaprint-v${CHROMAPRINT_VERSION} \
  && libtoolize --force \
  && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TOOLS=ON . \
  && make DESTDIR=/build install \
  && cp -av /build/* /

RUN wget https://archive.mozilla.org/pub/opus/opus-${OPUS_VERSION}.tar.gz \
  && tar xzf /opus-${OPUS_VERSION}.tar.gz -C / \
  && cd /opus-${OPUS_VERSION} \
  && ./configure --prefix=/usr --disable-static --disable-doc --disable-extra-programs --enable-custom-modes \
  && make DESTDIR=/build install \
  && cp -av /build/* /

RUN wget https://archive.mozilla.org/pub/opus/libopusenc-${OPUSENC_VERSION}.tar.gz \
  && tar xzf /libopusenc-${OPUSENC_VERSION}.tar.gz -C / \
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

ENV CXXFLAGS=-fpermissive
RUN wget https://audiofile.68k.org/audiofile-${AUDIOFILE_VERSION}.tar.gz \
  && tar xzf /audiofile-${AUDIOFILE_VERSION}.tar.gz -C / \
  && cd /audiofile-${AUDIOFILE_VERSION} \
  && ./configure --prefix=/usr --disable-docs --disable-examples --disable-static \
  && make DESTDIR=/build install \
  && cp -av /build/* /

ENV DESTDIR=/build
RUN bash -c "wget https://www.musicpd.org/download/mpd/${MPD_VERSION%.*}/mpd-${MPD_VERSION}.tar.xz{,.sig}" \
  && gpg --verify mpd-${MPD_VERSION}.tar.xz.sig mpd-${MPD_VERSION}.tar.xz \
  && tar xJvf /mpd-${MPD_VERSION}.tar.xz -C / \
  && cd /MPD-${MPD_VERSION} \
  && bash -c '[ -f autogen.sh ] && ./autogen.sh || true' \
  && bash -c '[ -f configure ] && ./configure --enable-dsd --prefix=/usr --sysconfdir=/etc --localstatedir=/var --runstatedir=/run && make DESTDIR=/build install || true' \
  && bash -c '[ -f meson.build ] && meson --prefix=/usr --sysconfdir=/etc --localstatedir=/var build && cd build && ninja && ninja install && strip -g /build/usr/bin/mpd || true' \
  && mkdir -p /build/var/lib/mpd/playlists

RUN mkdir -p /build/usr/share/midi || true \
  && wget https://freepats.zenvoid.org/freepats-20060219.tar.xz -O - | tar xvJ -C /build/usr/share/midi/

# cleanup
RUN rm -rvf /build/usr/share/man/* /build/usr/lib/pkgconfig /build/usr/lib/cmake /build/usr/share/aclocal /build/usr/include \
  && find /build/usr/bin -type f -executable -exec strip -g {} \; \
  && find /build/usr/lib -type f -name "*.so.*" -exec strip -g {} \; \
  && find /build/usr/lib -type f -name "*.la" -delete \
  && find /build/usr/lib -type f -name "*.a" -delete

ARG ALPINE_VERSION
FROM alpine:$ALPINE_VERSION AS runner

ARG S6_OVERLAY_VERSION=v2.2.0.3

# start on qnap with
# docker run -d  --cpus "1" --memory 256mb --cap-add SYS_NICE --net host -v var-lib-mpd:/var/lib/mpd -v /share/Music:/media/music:ro --device=/dev/snd:/dev/snd -e MPD_ALSA_NAME="USB Audio" -e MPD_ALSA_DEVICE="iec958:CARD=U0xccd0x77,DEV=0" --name mpd-1 --restart always gutmensch/mpd:latest
# and enable rt scheduling first on qnap with sysctl -w kernel.sched_rt_runtime_us=-1

LABEL maintainer="@gutmensch https://github.com/gutmensch"

# install s6 for mpd and ympd
RUN wget "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz" -O /tmp/s6-overlay-amd64.tar.gz \
  && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
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
	libupnp \
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
	expat \
	ncurses \
	fmt \
	liburing \
	pcre2 \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /var/lib/mpd/playlists \
    && wget -O - https://gitlab.com/sonida/mpd-configure/-/archive/master/mpd-configure-master.tar.gz | tar xzv --strip-components=1 -C /usr/bin/ \
    && mkdir -p /usr/bin/helpers \
    && wget -O /usr/bin/helpers/alsa-capabilities  https://gitlab.com/sonida/alsa-capabilities/-/raw/72d0521459460e8a1af824c47e9a5fcc02110405/alsa-capabilities

VOLUME ["/var/lib/mpd", "/media/music"]

COPY ./manifest/ /
COPY ./test/ /usr/build/test

# 6600 mpd port, 8800 mpd http output, ympd ui 8866
EXPOSE 6600 8800 8866

ENTRYPOINT ["/init"]
