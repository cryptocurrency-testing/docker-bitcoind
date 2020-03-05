FROM alpine as build

ARG bitcoind_version=v0.19.0.1
ARG host=x86_64-linux-gnu
RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add build-base
RUN apk --no-cache add curl
RUN apk --no-cache add git
RUN apk --no-cache add libtool
RUN apk --no-cache add pkgconfig

WORKDIR /
RUN git clone https://github.com/cryptocurrency-testing/bitcoin -b $bitcoind_version
RUN set -ex \
    && cd bitcoin \
    && make -j2 -C depends HOST=$host NO_QT=1 NO_UPNP=1 \
    && ./autogen.sh \
    && ./configure --with-incompatible-bdb --with-gui=no --disable-bench --disable-tests --with-zmq --host=$host --prefix=$PWD/depends/$host \
    && make -j2 HOST=$host

FROM alpine:latest
COPY --from=0 /bitcoin/src/bitcoind /usr/bin/bitcoind
RUN adduser -S bitcoin
ENV BITCOIN_DATA=/home/bitcoin/.bitcoin
COPY docker-entrypoint.sh /entrypoint.sh

EXPOSE 8332 8333 18332 18333 18444

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bitcoind"]
