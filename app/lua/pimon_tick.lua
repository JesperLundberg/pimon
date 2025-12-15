#!/usr/bin/env luajit

-- pimon_tick.lua
-- Collect Raspberry Pi / host metrics and store them in SQLite.
--
-- Frequency: 1 sample per real minute (via cron).
--
-- Notes:
-- - /proc stats (load/mem) are generally host-level even inside containers.
-- - Disk usage for host root is collected via a bind-mount of / -> /hostfs.

local config = require("pimon_config")
local utils = require("pimon_utils")

local function now_utc()
	-- SQLite-friendly UTC timestamp
	return utils.run_cmd("date -u '+%Y-%m-%d %H:%M:%S'")
end

local function cpu_load_last_minute()
	local s = utils.read_file("/proc/loadavg") or "0 0 0 0/0 0"
	local v = tonumber(s:match("^([%d%.]+)")) or 0.0
	return v
end

local function mem_kb()
	local meminfo = utils.read_file("/proc/meminfo") or ""
	local total = tonumber(meminfo:match("MemTotal:%s+(%d+)")) or 0
	local avail = tonumber(meminfo:match("MemAvailable:%s+(%d+)")) or 0
	return total, avail
end

-- Return disk usage percent for / on the HOST filesystem.
local function disk_used_pct()
	local raw = utils.run_cmd("df -P " .. config.HOST_FS .. "| awk 'NR==2{print $5}'") or ""
	-- Grab only the numbers of the returned value
	raw = raw:match("(%d+)")
	local disk_usage = tonumber(raw)
	return disk_usage or 0
end

local function cpu_temp_c()
	local raw = utils.read_file("/sys/class/thermal/thermal_zone0/temp")
	if not raw then
		return nil
	end
	local millicelsius = tonumber(raw)
	if not millicelsius then
		return nil
	end

	-- Convert from millicelsius to celsus with one decimal precision
	return millicelsius / 1000.0
end

local function init_schema(db)
	db:exec([[
    PRAGMA journal_mode=WAL;

    CREATE TABLE IF NOT EXISTS pi_tick (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      ts_utc       TEXT NOT NULL,
      load1        REAL NOT NULL,
      mem_total_kb INTEGER NOT NULL,
      mem_avail_kb INTEGER NOT NULL,
      disk_used_pct INTEGER NOT NULL,
      cpu_temp_c   REAL,
      notes        TEXT
    );
  ]])
end

local function insert_tick(db, row)
	local stmt = db:prepare([[
    INSERT INTO pi_tick (ts_utc, load1, mem_total_kb, mem_avail_kb, disk_used_pct, cpu_temp_c, notes)
    VALUES (?, ?, ?, ?, ?, ?, ?);
  ]])
	stmt:bind_values(
		row.ts_utc,
		row.load1,
		row.mem_total_kb,
		row.mem_avail_kb,
		row.disk_used_pct,
		row.cpu_temp_c,
		row.notes
	)
	stmt:step()
	stmt:finalize()
end

local function main()
	-- Ensure db directory exists on tmpfs
	utils.ensure_dir("/opt/pimon/db")

	local db = utils.open_db(config.DB_PATH)
	init_schema(db)

	local total_kb, avail_kb = mem_kb()

	local row = {
		ts_utc = now_utc(),
		load1 = cpu_load_last_minute(),
		mem_total_kb = total_kb,
		mem_avail_kb = avail_kb,
		disk_used_pct = disk_used_pct(),
		cpu_temp_c = cpu_temp_c(),
		notes = nil,
	}

	insert_tick(db, row)
	db:close()
end

main()
