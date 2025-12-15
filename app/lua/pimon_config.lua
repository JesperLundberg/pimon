local C = {}

C.DB_PATH     = "/opt/pimon/db/pimon.db"
C.ARCHIVE_DIR = "/opt/pimon/archive/"
C.JSON_PATH   = "/var/www/html/pimon/status.json"

-- Where to measure disk usage. We bind-mount host / to /hostfs in docker-compose.
C.HOST_FS     = "/hostfs"

return C
