ARG OPENHAB_VERSION=2.5.9
ARG S6_OVERLAY_PLATFORM=armhf
ARG S6_OVERLAY_VERSION=2.1.0.0

################################################################################

# patch entrypoint.sh
FROM openhab/openhab:$OPENHAB_VERSION as patched_entrypoint
COPY ./entrypoint.sh.patch /
RUN apt-get update && \
    apt-get install -y patch && \
    patch /entrypoint.sh < /entrypoint.sh.patch

################################################################################

# download and extract the s6 tarball
FROM alpine:latest as s6
ARG S6_OVERLAY_PLATFORM
ARG S6_OVERLAY_VERSION
ARG TARGETPLATFORM
COPY ./get_s6.sh /
RUN apk add curl && /get_s6.sh

################################################################################

FROM openhab/openhab:${OPENHAB_VERSION}

COPY ./root /

# setup s6 overlay
COPY --from=s6 /s6 /
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# add patched entrypoint.sh
COPY --from=patched_entrypoint /entrypoint.sh /entrypoint.sh

# install bluez
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        bluez && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# run s6 init
ENTRYPOINT ["/init"]

# default command to run
CMD ["gosu", "openhab", "tini", "-s", "/openhab/start.sh", "server"]
