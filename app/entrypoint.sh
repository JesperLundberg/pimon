#!/bin/sh
set -e

# Ensure DB directory exists on tmpfs
mkdir -p /opt/pimon/db

# If a backup exists on disk, restore it into tmpfs
if [ -f /opt/pimon/backups/pimon.db ]; then
  cp /opt/pimon/backups/pimon.db /opt/pimon/db/pimon.db
fi

# busybox crond passes its own environment (TZ, LUA_PATH, LUA_CPATH from the
# image ENV) on to every job.

# Take a final backup on shutdown so a `docker stop` loses no data.
crond -f -l 8 -c /etc/crontabs &
CRON_PID=$!

# Host networking: this binds port 8088 on the host.
httpd -f -p 8088 -h /var/www/html &
HTTPD_PID=$!

shutdown() {
  kill "$CRON_PID" "$HTTPD_PID" 2>/dev/null || true
  /opt/pimon/backup.sh || true
  exit 0
}
trap shutdown TERM INT

# `wait` returns when a trapped signal arrives; cron itself never exits normally.
wait "$CRON_PID"
