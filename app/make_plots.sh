#!/bin/sh
set -eu

PLOT_DIR="/opt/pimon/plots"
OUT_DIR="/var/www/html/pimon"
mkdir -p "$OUT_DIR"

DB="/opt/pimon/db/pimon.db"
WINDOW="-1 day"

run_plot() {
  size="$1"
  plot="$2"
  out="$3"
  title="$4"
  ylab="$5"
  col="$6"

  gnuplot -e "PLOT_DIR='$PLOT_DIR'; DB='$DB'; WINDOW='$WINDOW'; OUT='$out'; TITLE='$title'; YLAB='$ylab'; COL='$col'" \
    "$PLOT_DIR/$size" "$PLOT_DIR/$plot"
}

run_plot_two() {
  size="$1"
  plot="$2"
  out="$3"
  title="$4"
  ylab="$5"
  col_a="$6"
  col_b="$7"
  label_a="$8"
  label_b="$9"

  gnuplot -e "PLOT_DIR='$PLOT_DIR'; DB='$DB'; WINDOW='$WINDOW'; OUT='$out'; TITLE='$title'; YLAB='$ylab'; COL_A='$col_a'; COL_B='$col_b'; LABEL_A='$label_a'; LABEL_B='$label_b'" \
    "$PLOT_DIR/$size" "$PLOT_DIR/$plot"
}


# Desktop
run_plot "size_desktop.gp" "plot_single_sql.gp" "$OUT_DIR/load.png"        "CPU Load (1m) - last 24h" "load1" "load1"
run_plot "size_desktop.gp" "plot_single_sql.gp" "$OUT_DIR/mem_avail.png"   "MemAvailable - last 24h"  "KB"    "mem_avail_kb"
run_plot "size_desktop.gp" "plot_single_sql.gp" "$OUT_DIR/cpu_temp.png"    "CPU temp - last 24h"      "C"     "cpu_temp_c"
run_plot "size_desktop.gp" "plot_single_sql.gp" "$OUT_DIR/vm_wa.png"       "IO wait (wa) - last 24h"  "%"     "vm_wa"
run_plot "size_desktop.gp" "plot_single_sql.gp" "$OUT_DIR/vm_r.png"        "Run queue (r) - last 24h" "r"     "vm_r"
run_plot "size_desktop.gp" "plot_single_sql.gp" "$OUT_DIR/vm_idle.png"     "CPU idle - last 24h"      "%"     "vm_id" "[0:100]"

run_plot_two "size_desktop.gp" "plot_two_sql.gp" "$OUT_DIR/vm_swap.png" "Swap activity (si / so) - last 24h" "pages/s" "vm_si" "vm_so" "si" "so"

# Mobile
run_plot "size_mobile.gp" "plot_single_sql.gp" "$OUT_DIR/load_mobile.png"      "CPU Load (1m) - 24h" "load1" "load1"
run_plot "size_mobile.gp" "plot_single_sql.gp" "$OUT_DIR/mem_avail_mobile.png" "MemAvailable - 24h"  "KB"    "mem_avail_kb"
run_plot "size_mobile.gp" "plot_single_sql.gp" "$OUT_DIR/cpu_temp_mobile.png"  "CPU temp - 24h"      "C"     "cpu_temp_c"
run_plot "size_mobile.gp" "plot_single_sql.gp" "$OUT_DIR/vm_wa_mobile.png"     "IO wait (wa) - 24h"  "%"     "vm_wa"
run_plot "size_mobile.gp" "plot_single_sql.gp" "$OUT_DIR/vm_r_mobile.png"      "Run queue (r) - 24h" "r"     "vm_r"
run_plot "size_mobile.gp" "plot_single_sql.gp" "$OUT_DIR/vm_idle_mobile.png"   "CPU idle - last 24h" "%"     "vm_id" "[0:100]"

run_plot_two "size_mobile.gp" "plot_two_sql.gp" "$OUT_DIR/vm_swap_mobile.png" "Swap activity (si / so) - 24h" "pages/s" "vm_si" "vm_so" "si" "so"
