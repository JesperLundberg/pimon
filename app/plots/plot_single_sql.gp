# Generic single-series SQLite-backed plot.
# Required vars passed via -e:
#   W, H      -> image size
#   OUT       -> output png path
#   TITLE     -> plot title
#   YLAB      -> y-axis label
#   COL       -> SQLite column name (e.g. load1, mem_avail_kb)
# Optional vars:
#   DB        -> SQLite db path (default: /opt/pimon/db/pimon.db)
#   WINDOW    -> sqlite datetime window (default: -1 day)
#   LINECOLOR -> line color (default: #1e66f5)
#   LW        -> line width (default: 2)

load sprintf("%s/common.gp", PLOT_DIR)

if (!exists("DB")) DB = "/opt/pimon/db/pimon.db"
if (!exists("WINDOW")) WINDOW = "-1 day"
if (!exists("LINECOLOR")) LINECOLOR = "#1e66f5"
if (!exists("LW")) LW = 2

if (exists("YRANGE")) {
  set yrange YRANGE
}

set terminal pngcairo size W,H enhanced font ",10"
set output OUT

set title TITLE textcolor rgb "#4c4f69"
set ylabel YLAB textcolor rgb "#4c4f69"

# Build sqlite3 command as a gnuplot input stream.
CMD = sprintf("< sqlite3 -noheader -separator '|' '%s' \"SELECT datetime(ts_utc,'localtime'), %s FROM pi_tick WHERE ts_utc >= datetime('now','localtime','%s') ORDER BY id;\"", DB, COL, WINDOW)
plot CMD using 1:2 with lines lw LW lc rgb LINECOLOR title ""
