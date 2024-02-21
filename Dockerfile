FROM debian:bookworm-slim

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && apt-get install -y \
        bash \
        curl \
        xz-utils \
        netcat-openbsd \
        inetutils-ping \
        inetutils-traceroute \
    && rm -rf /var/lib/apt/lists/*

ENV TARGET_HOST=1.1.1.1
ENV TARGET_PORT=80
ENV TARGET_CHECK_INTERVAL=2
ENV TARGET_CHECK_MAX_HOP=15

# https://github.com/socheatsok78/s6-overlay-installer
ARG S6_OVERLAY_VERSION=v3.1.5.0
ARG S6_OVERLAY_INSTALLER=main/s6-overlay-installer-minimal.sh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/socheatsok78/s6-overlay-installer/${S6_OVERLAY_INSTALLER})"
ENTRYPOINT [ "/init-shim", "/docker-entrypoint.sh" ]
CMD [ "sleep", "infinity" ]

ADD rootfs /
