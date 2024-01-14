FROM docker.io/library/debian:12.4-slim as builder

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && apt-get install -y --no-install-recommends \
 build-essential=12.9 \
 ca-certificates=20230311 \
 git=1:2.39.2-1.1 \
 sudo=1.9.13p3-1+deb12u1
 # Not removing cache here because the deps.sh script can use it.
 # The cache will not be in the final stage of the image anyway.

RUN mkdir /simh \
 && git clone --depth 1 https://github.com/open-simh/simh.git /simh \
 && /simh/.travis/deps.sh linux \
 && /simh/cmake/cmake-builder.sh --novideo --noinstall --parallel --target pdp11

# FROM gcr.io/distroless/base-debian12:nonroot
FROM gcr.io/distroless/base-debian12@sha256:684dee415923cb150793530f7997c96b3cef006c868738a2728597773cf27359

COPY --from=builder /usr/lib/x86_64-linux-gnu/libvdeplug.so.2 /usr/lib/x86_64-linux-gnu/libvdeplug.so.2
COPY --from=builder /lib/x86_64-linux-gnu/libpcre.so.3 /lib/x86_64-linux-gnu/libpcre.so.3
COPY --from=builder /usr/lib/x86_64-linux-gnu/libedit.so.2 /usr/lib/x86_64-linux-gnu/libedit.so.2
COPY --from=builder /usr/lib/x86_64-linux-gnu/libbsd.so.0 /usr/lib/x86_64-linux-gnu/libbsd.so.0
COPY --from=builder /usr/lib/x86_64-linux-gnu/libtinfo.so.6 /usr/lib/x86_64-linux-gnu/libtinfo.so.6
COPY --from=builder /usr/lib/x86_64-linux-gnu/libmd.so.0 /usr/lib/x86_64-linux-gnu/libmd.so.0

COPY --from=builder /simh/BIN/pdp11 /bin/pdp11
ENTRYPOINT ["/bin/pdp11"]
