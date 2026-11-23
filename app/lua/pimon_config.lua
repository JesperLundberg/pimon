local C = {}

C.DB_DIR      = "/opt/pimon/db"
C.DB_PATH     = C.DB_DIR .. "/pimon.db"
C.ARCHIVE_DIR = "/opt/pimon/archive"
C.JSON_DIR    = "/var/www/html/pimon"
C.JSON_PATH   = C.JSON_DIR .. "/status.json"

-- Where to measure disk usage. We bind-mount host / to /hostfs in docker-compose.
C.HOST_FS     = "/hostfs"

-- Rows older than this are exported to a CSV in ARCHIVE_DIR and then deleted.
-- The DB lives on a small tmpfs, so this bounds its size.
C.RETENTION_DAYS = 30

return C
