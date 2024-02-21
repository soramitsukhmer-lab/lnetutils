FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
        bash \
        curl     \
        netcat-openbsd \
        inetutils-ping \
        inetutils-traceroute \
    && rm -rf /var/lib/apt/lists/*

ENV TARGET_ADDR=1.1.1.1
ENV TARGET_ANALYSE_INTERVAL=2
ENV TARGET_ANALYSE_TIMEOUT=60

ADD rootfs /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
