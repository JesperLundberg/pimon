#!/bin/sh
set -eu

PLOT_DIR="/opt/pimon/plots"
OUT_DIR="/var/www/html/pimon"
mkdir -p "$OUT_DIR"

DB="/opt/pimon/db/pimon.db"
WINDOW="-1 day"

run_plot() {
  wrapper="$1"   # size_desktop.gp or size_mobile.gp
  out="$2"
  title="$3"
  ylab="$4"
  col="$5"

  gnuplot -e "PLOT_DIR='$PLOT_DIR'; DB='$DB'; WINDOW='$WINDOW'; OUT='$out'; TITLE='$title'; YLAB='$ylab'; COL='$col'" \
  "$PLOT_DIR/$wrapper"
}

# Desktop
run_plot "size_desktop.gp" "$OUT_DIR/load.png"        "CPU Load (1m) - last 24h" "load1" "load1"
run_plot "size_desktop.gp" "$OUT_DIR/mem_avail.png"   "MemAvailable - last 24h"  "KB"    "mem_avail_kb"
run_plot "size_desktop.gp" "$OUT_DIR/cpu_temp.png"    "CPU temp - last 24h"      "C"     "cpu_temp_c"

# Mobile
run_plot "size_mobile.gp"  "$OUT_DIR/load_mobile.png"      "CPU Load (1m) - 24h" "load1" "load1"
run_plot "size_mobile.gp"  "$OUT_DIR/mem_avail_mobile.png" "MemAvailable - 24h"  "KB"    "mem_avail_kb"
run_plot "size_mobile.gp"  "$OUT_DIR/cpu_temp_mobile.png"  "CPU temp - 24h"      "C"     "cpu_temp_c"
