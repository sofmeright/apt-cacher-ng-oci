FROM ubuntu:24.04

LABEL maintainer="sofmeright@gmail.com"

ENV APT_CACHER_NG_VERSION=3.7.4 \
    APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
    APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
    APT_CACHER_NG_USER=apt-cacher-ng

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
      apt-cacher-ng=${APT_CACHER_NG_VERSION}* ca-certificates gosu wget

# Enable foreground mode and redirect logs to stdout
RUN sed -i 's|# ForeGround: .*|ForeGround: 1|' /etc/apt-cacher-ng/acng.conf \
 && sed -i 's|# Logfile: .*|Logfile: /dev/stdout|' /etc/apt-cacher-ng/acng.conf \
 && sed -i 's|# PassThroughPattern:.*|PassThroughPattern: .* #|' /etc/apt-cacher-ng/acng.conf

RUN rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3142/tcp

HEALTHCHECK --interval=10s --timeout=2s --retries=3 \
    CMD wget -q -t1 -O /dev/null  http://localhost:3142/acng-report.html || exit 1

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/apt-cacher-ng"]
