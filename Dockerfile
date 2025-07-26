FROM ubuntu:24.04

LABEL maintainer="sofmeright@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive \
    APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
    APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
    APT_CACHER_NG_USER=apt-cacher-ng \
    PASS_THROUGH_PATTERN='.*'

# Install tini and apt-cacher-ng and gosu
RUN apt-get update && apt-get install -y --no-install-recommends \
      apt-cacher-ng tini gosu ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Patch config: set ForeGround mode and passthrough pattern
RUN sed -i 's|# ForeGround: .*|ForeGround: 1|' /etc/apt-cacher-ng/acng.conf && \
    sed -i 's|# LogDir: .*|LogDir: /var/log/apt-cacher-ng|' /etc/apt-cacher-ng/acng.conf && \
    grep -q '^PassThroughPattern:' /etc/apt-cacher-ng/acng.conf && \
      sed -i "s|^PassThroughPattern:.*|PassThroughPattern: ${PASS_THROUGH_PATTERN}|" /etc/apt-cacher-ng/acng.conf || \
      echo "PassThroughPattern: ${PASS_THROUGH_PATTERN}" >> /etc/apt-cacher-ng/acng.conf

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh

EXPOSE 3142

ENTRYPOINT ["/usr/bin/tini", "-s", "--", "/sbin/entrypoint.sh"]
CMD []
