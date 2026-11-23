# pimon

Lightweight Raspberry Pi monitor. Cron jobs in the `pimon` container sample
system metrics into SQLite, render PNG plots with gnuplot, and write a
`status.json`. Busybox `httpd` in the same container serves a static page that shows them.

## Run

```sh
docker compose up -d --build
```

Open `http://<host>:8088/pimon.html`.

## How it works

| Job | Schedule | What |
| --- | --- | --- |
| `pimon_tick.lua` | every 2 min | Sample load, memory, disk, CPU temp, vmstat into SQLite |
| `make_plots.sh` | every 5 min | Render the 24h plots (desktop + mobile sizes) |
| `pimon_status.lua` | every minute | Write `status.json` for the status cards |
| `backup.sh` | hourly | Copy the tmpfs DB to `./data/pimon.db` |
| `pimon_rotate.lua` | weekly | Archive rows older than `RETENTION_DAYS` to CSV in `./data/archive`, then delete them |

- The database lives on a tmpfs (to spare the SD card). It is restored from
  `./data/pimon.db` on start and backed up hourly and on `docker stop`.
  A hard power loss loses up to an hour of samples.
- Timestamps are stored in UTC and shown in local time (`TZ` is set in the
  Dockerfile and compose file; change both together. busybox `crond` passes
  that environment on to the jobs).
- Job output goes to the container's stdout: `docker logs pimon`.

## Configuration

- `app/lua/pimon_config.lua`: paths and `RETENTION_DAYS`.
- `app/make_plots.sh`: `WINDOW_HOURS` and the list of plots.
- `app/crontab`: schedules.

## Tests

```sh
cd app && luajit tests/test_vmstat.lua
```
