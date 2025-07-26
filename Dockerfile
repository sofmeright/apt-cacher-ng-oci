FROM ubuntu:24.04

LABEL maintainer="sofmeright@gmail.com"

ENV APT_CACHER_NG_VERSION=3.7.4 \
    APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
    APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
    APT_CACHER_NG_USER=apt-cacher-ng \
    PASS_THROUGH_PATTERN='.*'

# Install tini for proper PID 1 and signal handling
# Install apt-cacher-ng and dependencies
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
      apt-cacher-ng=${APT_CACHER_NG_VERSION}* \
      ca-certificates gosu tini wget \
 && rm -rf /var/lib/apt/lists/*

# Patch config for foreground and pass-through pattern
RUN sed -i 's|# ForeGround: .*|ForeGround: 1|' /etc/apt-cacher-ng/acng.conf \
 && sed -i 's|# PassThroughPattern: .*|PassThroughPattern: '"${PASS_THROUGH_PATTERN}"'|' /etc/apt-cacher-ng/acng.conf

# Copy entrypoint script
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh

EXPOSE 3142/tcp

ENTRYPOINT ["/usr/bin/tini", "--", "/sbin/entrypoint.sh"]
CMD []
