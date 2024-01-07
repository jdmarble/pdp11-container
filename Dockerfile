FROM docker.io/library/debian:12.4-slim as builder

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y build-essential git sudo

RUN mkdir /simh \
 && git clone --depth 1 https://github.com/open-simh/simh.git /simh 

RUN /simh/.travis/deps.sh linux

RUN /simh/cmake/cmake-builder.sh --novideo --noinstall --parallel --target pdp11

FROM gcr.io/distroless/base-debian12

COPY --from=builder /usr/lib/x86_64-linux-gnu/libvdeplug.so.2 /usr/lib/x86_64-linux-gnu/libvdeplug.so.2
COPY --from=builder /lib/x86_64-linux-gnu/libpcre.so.3 /lib/x86_64-linux-gnu/libpcre.so.3
COPY --from=builder /usr/lib/x86_64-linux-gnu/libedit.so.2 /usr/lib/x86_64-linux-gnu/libedit.so.2
COPY --from=builder /usr/lib/x86_64-linux-gnu/libbsd.so.0 /usr/lib/x86_64-linux-gnu/libbsd.so.0
COPY --from=builder /usr/lib/x86_64-linux-gnu/libtinfo.so.6 /usr/lib/x86_64-linux-gnu/libtinfo.so.6
COPY --from=builder /usr/lib/x86_64-linux-gnu/libmd.so.0 /usr/lib/x86_64-linux-gnu/libmd.so.0

COPY --from=builder /simh/BIN/pdp11 /bin/pdp11
ENTRYPOINT ["/bin/pdp11"]
