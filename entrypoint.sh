#!/bin/bash
set -e

# Create necessary directories with correct ownership and permissions
create_dirs() {
  mkdir -p /run/apt-cacher-ng "${APT_CACHER_NG_CACHE_DIR}" "${APT_CACHER_NG_LOG_DIR}"
  chown -R "${APT_CACHER_NG_USER}:${APT_CACHER_NG_USER}" /run/apt-cacher-ng "${APT_CACHER_NG_CACHE_DIR}" "${APT_CACHER_NG_LOG_DIR}"
}

create_dirs

# Allow runtime override of PassThroughPattern via environment variable (optional)
if [[ -n "${PASS_THROUGH_PATTERN}" ]]; then
  sed -i "s|^PassThroughPattern:.*|PassThroughPattern: ${PASS_THROUGH_PATTERN}|" /etc/apt-cacher-ng/acng.conf
fi

# Start apt-cacher-ng in foreground as apt-cacher-ng user
exec su-exec ${APT_CACHER_NG_USER} /usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng ForeGround=1 &

# Wait a moment to ensure log files are created
sleep 1

# Tail logs to stdout (container logs)
exec tail -F "${APT_CACHER_NG_LOG_DIR}/apt-cacher.log" "${APT_CACHER_NG_LOG_DIR}/error.log"
