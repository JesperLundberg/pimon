#!/bin/sh
set -eu

# Copy the tmpfs database to disk. Write to a temp file first so a crash
# mid-backup cannot corrupt the previous good backup.
DB="/opt/pimon/db/pimon.db"
DEST="/opt/pimon/backups/pimon.db"

[ -f "$DB" ] || exit 0

sqlite3 "$DB" ".backup '$DEST.tmp'"
mv "$DEST.tmp" "$DEST"
