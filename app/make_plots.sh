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

run_plot_two() {
  wrapper="$1"   # size_desktop.gp or size_mobile.gp
  out="$2"
  title="$3"
  ylab="$4"
  col_a="$5"
  col_b="$6"
  label_a="$7"
  label_b="$8"

  gnuplot -e "PLOT_DIR='$PLOT_DIR';DB='$DB';WINDOW='$WINDOW';OUT='$out';TITLE='$title';YLAB='$ylab';COL_A='$col_a';COL_B='$col_b';LABEL_A='$label_a';LABEL_B='$label_b';" \
    "$PLOT_DIR/plot_two_sql.gp"
}

# Desktop
run_plot "size_desktop.gp" "$OUT_DIR/load.png"        "CPU Load (1m) - last 24h" "load1" "load1"
run_plot "size_desktop.gp" "$OUT_DIR/mem_avail.png"   "MemAvailable - last 24h"  "KB"    "mem_avail_kb"
run_plot "size_desktop.gp" "$OUT_DIR/cpu_temp.png"    "CPU temp - last 24h"      "C"     "cpu_temp_c"
run_plot "size_desktop.gp" "$OUT_DIR/vm_wa.png"        "IO wait (wa) - last 24h" "%" "vm_wa"
run_plot "size_desktop.gp" "$OUT_DIR/vm_r.png"        "Run queue (r) - last 24h" "r" "vm_r"
run_plot "size_desktop.gp" "$OUT_DIR/vm_idle.png"        "CPU idle - last 24h" "%" "vm_id"

run_plot_two "size_desktop.gp" "$OUT_DIR/vm_swap.png" "Swap activity (si / so) - last 24h" "pages/s" "vm_si" "vm_so" "si" "so"

# Mobile
run_plot "size_mobile.gp"  "$OUT_DIR/load_mobile.png"      "CPU Load (1m) - 24h" "load1" "load1"
run_plot "size_mobile.gp"  "$OUT_DIR/mem_avail_mobile.png" "MemAvailable - 24h"  "KB"    "mem_avail_kb"
run_plot "size_mobile.gp"  "$OUT_DIR/cpu_temp_mobile.png"  "CPU temp - 24h"      "C"     "cpu_temp_c"
run_plot "size_mobile.gp"  "$OUT_DIR/vm_wa_mobile.png" "IO wait (wa) - 24h"      "%" "vm_wa"
run_plot "size_mobile.gp"  "$OUT_DIR/vm_r_mobile.png" "Run queue (r) - 24h"      "r" "vm_r"
run_plot "size_mobile.gp"  "$OUT_DIR/vm_idle_mobile.png" "CPU idle - 24h"      "%" "vm_id"

run_plot_two "size_mobile.gp" "$OUT_DIR/vm_swap_mobile.png" "Swap activity (si / so) - last 24h" "pages/s" "vm_si" "vm_so" "si" "so"
