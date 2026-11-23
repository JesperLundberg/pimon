#!/bin/sh
set -eu

PLOT_DIR="/opt/pimon/plots"
OUT_DIR="/var/www/html/pimon"
mkdir -p "$OUT_DIR"

DB="/opt/pimon/db/pimon.db"

# Single source for the plotted window; titles are derived from it.
WINDOW_HOURS=24
WINDOW="-${WINDOW_HOURS} hours"

run_plot() {
  size="$1"
  plot="$2"
  out="$3"
  title="$4"
  ylab="$5"
  col="$6"
  ymin="${7:-}"
  ymax="${8:-}"

  extra=""
  if [ -n "$ymin" ] && [ -n "$ymax" ]; then
    extra="; YMIN=$ymin; YMAX=$ymax"
  fi

  gnuplot -e "PLOT_DIR='$PLOT_DIR'; DB='$DB'; WINDOW='$WINDOW'; OUT='$out'; TITLE='$title'; YLAB='$ylab'; COL='$col'$extra" \
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

# Mobile files get a "_mobile" suffix and a shorter title.
for variant in desktop mobile; do
  if [ "$variant" = "desktop" ]; then
    size="size_desktop.gp"
    sfx=""
    span="last ${WINDOW_HOURS}h"
  else
    size="size_mobile.gp"
    sfx="_mobile"
    span="${WINDOW_HOURS}h"
  fi

  run_plot "$size" "plot_single_sql.gp" "$OUT_DIR/load${sfx}.png"      "CPU Load (1m) - $span" "load1" "load1"
  run_plot "$size" "plot_single_sql.gp" "$OUT_DIR/mem_avail${sfx}.png" "MemAvailable - $span"  "KB"    "mem_avail_kb"
  run_plot "$size" "plot_single_sql.gp" "$OUT_DIR/cpu_temp${sfx}.png"  "CPU temp - $span"      "C"     "cpu_temp_c"
  run_plot "$size" "plot_single_sql.gp" "$OUT_DIR/vm_wa${sfx}.png"     "IO wait (wa) - $span"  "%"     "vm_wa"
  run_plot "$size" "plot_single_sql.gp" "$OUT_DIR/vm_r${sfx}.png"      "Run queue (r) - $span" "r"     "vm_r"
  run_plot "$size" "plot_single_sql.gp" "$OUT_DIR/vm_idle${sfx}.png"   "CPU idle - $span"      "%"     "vm_id" 0 100

  # procps vmstat reports swap in kB/s.
  run_plot_two "$size" "plot_two_sql.gp" "$OUT_DIR/vm_swap${sfx}.png" "Swap activity (si / so) - $span" "kB/s" "vm_si" "vm_so" "si" "so"
done
