#!/bin/sh
set -eu

PLOT_DIR="/opt/pimon/plots"
OUT_DIR="/var/www/html/pimon"

mkdir -p "$OUT_DIR"

# Desktop charts
gnuplot "$PLOT_DIR/plot_load.gnuplot"
gnuplot "$PLOT_DIR/plot_mem_avail.gnuplot"
gnuplot "$PLOT_DIR/plot_disk_used.gnuplot"
gnuplot "$PLOT_DIR/plot_cpu_temp.gnuplot"

# Mobile charts (optional)
gnuplot "$PLOT_DIR/plot_load_mobile.gnuplot"
gnuplot "$PLOT_DIR/plot_mem_avail_mobile.gnuplot"
gnuplot "$PLOT_DIR/plot_disk_used_mobile.gnuplot"
gnuplot "$PLOT_DIR/plot_cpu_temp_mobile.gnuplot"
