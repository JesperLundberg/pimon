#!/bin/sh
set -e

# Ensure DB directory exists on tmpfs
mkdir -p /opt/pimon/db

# If a backup exists on disk, restore it into tmpfs
if [ -f /opt/pimon/backups/pimon.db ]; then
  cp /opt/pimon/backups/pimon.db /opt/pimon/db/pimon.db
fi

export LUA_PATH="/opt/pimon/lua/?.lua;/opt/pimon/lua/?/init.lua;;"

# Start cron in the foreground
exec cron -f
