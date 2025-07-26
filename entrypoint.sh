#!/bin/bash
set -e

CACHE_DIR="${APT_CACHER_NG_CACHE_DIR}"
LOG_DIR="${APT_CACHER_NG_LOG_DIR}"

# Ensure required directories exist
mkdir -p /run/apt-cacher-ng "$CACHE_DIR" "$LOG_DIR"
chown -R "$APT_CACHER_NG_USER:$APT_CACHER_NG_USER" /run/apt-cacher-ng "$CACHE_DIR" "$LOG_DIR"

# Optional: allow override of PassThroughPattern at runtime
if [[ -n "${PASS_THROUGH_PATTERN}" ]]; then
  sed -i "s|^PassThroughPattern:.*|PassThroughPattern: ${PASS_THROUGH_PATTERN}|" /etc/apt-cacher-ng/acng.conf
fi

# Start apt-cacher-ng in foreground as proper user
gosu "$APT_CACHER_NG_USER" /usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng ForeGround=1 &

# Wait for log files to appear (gracefully)
LOG_FILES=("$LOG_DIR/apt-cacher.log" "$LOG_DIR/error.log")
for file in "${LOG_FILES[@]}"; do
  echo "Waiting for log file $file to appear..."
  while [ ! -f "$file" ]; do sleep 0.5; done
done

# Stream logs to stdout
exec tail -f /var/log/apt-cacher-ng/apt-cacher.log
