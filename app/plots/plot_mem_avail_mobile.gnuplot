set terminal pngcairo size 420,260 enhanced font ",10"
set datafile separator "|"

# Light Catppuccin Latte background
set object 1 rectangle from screen 0,0 to screen 1,1 behind \
    fillcolor rgb "#eff1f5" fillstyle solid 1.0

set border lc rgb "#4c4f69"
set grid lc rgb "#ccd0da"
set tics textcolor rgb "#4c4f69"
set key textcolor rgb "#4c4f69"

set yrange [0:*]
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%H:%M\n%d/%m"

set output "/var/www/html/pimon/mem_avail_mobile.png"
set title "MemAvailable - 24h" textcolor rgb "#4c4f69"
set ylabel "KB" textcolor rgb "#4c4f69"

plot "< sqlite3 /opt/pimon/db/pimon.db \"SELECT ts_utc, mem_avail_kb FROM pi_tick WHERE ts_utc >= datetime('now','-1 day') ORDER BY id;\"" using 1:2 with lines lw 2 lc rgb "#1e66f5" title ""
