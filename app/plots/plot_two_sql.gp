# Generic two-series SQLite-backed plot.
# Required vars passed via -e:
#   W, H      -> image size
#   OUT       -> output png path
#   TITLE     -> plot title
#   YLAB      -> y-axis label
#   COL_A     -> first SQLite column name
#   COL_B     -> second SQLite column name
# Optional vars:
#   DB        -> SQLite db path (default: /opt/pimon/db/pimon.db)
#   WINDOW    -> sqlite datetime window (default: -1 day)
#   LINECOLOR_A -> color for first line (default: #1e66f5)
#   LINECOLOR_B -> color for second line (default: #40a02b)
#   LW        -> line width (default: 2)
#   LABEL_A   -> legend label for first line (default: COL_A)
#   LABEL_B   -> legend label for second line (default: COL_B)

load sprintf("%s/common.gp", PLOT_DIR)

if (!exists("DB")) DB = "/opt/pimon/db/pimon.db"
if (!exists("WINDOW")) WINDOW = "-1 day"
if (!exists("LINECOLOR_A")) LINECOLOR_A = "#1e66f5"
if (!exists("LINECOLOR_B")) LINECOLOR_B = "#40a02b"
if (!exists("LW")) LW = 2
if (!exists("LABEL_A")) LABEL_A = COL_A
if (!exists("LABEL_B")) LABEL_B = COL_B

set terminal pngcairo size W,H enhanced font ",10"
set output OUT

set title TITLE textcolor rgb "#4c4f69"
set ylabel YLAB textcolor rgb "#4c4f69"

# Build sqlite3 commands as gnuplot input streams.
CMD_A = sprintf("< sqlite3 -noheader -separator '|' '%s' \"SELECT datetime(ts_utc,'localtime'), %s FROM pi_tick WHERE ts_utc >= datetime('now','localtime','%s') ORDER BY id;\"", DB, COL_A, WINDOW)
CMD_B = sprintf("< sqlite3 -noheader -separator '|' '%s' \"SELECT datetime(ts_utc,'localtime'), %s FROM pi_tick WHERE ts_utc >= datetime('now','localtime','%s') ORDER BY id;\"", DB, COL_B, WINDOW)

plot \
  CMD_A using 1:2 with lines lw LW lc rgb LINECOLOR_A title LABEL_A, \
  CMD_B using 1:2 with lines lw LW lc rgb LINECOLOR_B title LABEL_B
