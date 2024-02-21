FROM debian:bookworm-slim

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && apt-get install -y \
        bash \
        curl     \
        netcat-openbsd \
        inetutils-ping \
        inetutils-traceroute \
    && rm -rf /var/lib/apt/lists/*

ENV TARGET_HOST=1.1.1.1
ENV TARGET_PORT=80
ENV TARGET_ANALYSE_INTERVAL=2

ADD rootfs /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
