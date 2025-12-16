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
	local s = utils.get_value("/proc/loadavg") or "0 0 0 0/0 0"
	local v = tonumber(s:match("^([%d%.]+)")) or 0.0
	return v
end

local function mem_kb()
	local meminfo = utils.get_value("/proc/meminfo") or ""
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
	local raw = utils.get_value("/sys/class/thermal/thermal_zone0/temp")
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

local function parse_vmstat_line(line)
	-- Typical columns:
	-- r b swpd free buff cache si so bi bo in cs us sy id wa st
	local cols = {}
	for tok in line:gmatch("%S+") do
		cols[#cols + 1] = tok
	end

	-- Guard: we need at least up to "id" and ideally "wa"
	if #cols < 17 then
		error("vmstat output too short: " .. line, 0)
	end

	local v = {
		r = tonumber(cols[1]) or 0,
		b = tonumber(cols[2]) or 0,
		si = tonumber(cols[11]) or 0,
		so = tonumber(cols[12]) or 0,
		bi = tonumber(cols[13]) or 0,
		bo = tonumber(cols[14]) or 0,
		us = tonumber(cols[15]) or 0,
		sy = tonumber(cols[16]) or 0,
		id = tonumber(cols[17]) or 0,
		wa = tonumber(cols[18]) or 0, -- some builds omit wa/st; if missing it becomes nil -> 0
	}

	return v
end

local function get_vmstat_sample()
	local line = utils.run_cmd("vmstat 1 2 | tail -1")
	return parse_vmstat_line(line)
end

local function init_schema(db)
	db:exec([[
    PRAGMA journal_mode=WAL;

    CREATE TABLE IF NOT EXISTS pi_tick (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      ts_utc        TEXT NOT NULL,
      load1         REAL NOT NULL,
      mem_total_kb  INTEGER NOT NULL,
      mem_avail_kb  INTEGER NOT NULL,
      disk_used_pct INTEGER NOT NULL,
      cpu_temp_c    REAL,

      -- vmstat fields
      vm_r          INTEGER NOT NULL,
      vm_si         INTEGER NOT NULL,
      vm_so         INTEGER NOT NULL,
      vm_wa         INTEGER NOT NULL,
      vm_us         INTEGER NOT NULL,
      vm_sy         INTEGER NOT NULL,
      vm_id         INTEGER NOT NULL,
      vm_bi         INTEGER NOT NULL,
      vm_bo         INTEGER NOT NULL,

      notes         TEXT
    );
  ]])
end

local function insert_tick(db, row)
	local stmt = db:prepare([[
    INSERT INTO pi_tick (
      ts_utc, load1, mem_total_kb, mem_avail_kb, disk_used_pct, cpu_temp_c,
      vm_r, vm_si, vm_so, vm_wa, vm_us, vm_sy, vm_id, vm_bi, vm_bo,
      notes
    )
    VALUES (
      ?, ?, ?, ?, ?, ?,
      ?, ?, ?, ?, ?, ?, ?, ?, ?,
      ?
    );
  ]])

	stmt:bind_values(
		row.ts_utc,
		row.load1,
		row.mem_total_kb,
		row.mem_avail_kb,
		row.disk_used_pct,
		row.cpu_temp_c,
		row.vm_r,
		row.vm_si,
		row.vm_so,
		row.vm_wa,
		row.vm_us,
		row.vm_sy,
		row.vm_id,
		row.vm_bi,
		row.vm_bo,
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
	local vm = get_vmstat_sample()

	local row = {
		ts_utc = now_utc(),
		load1 = cpu_load_last_minute(),
		mem_total_kb = total_kb,
		mem_avail_kb = avail_kb,
		disk_used_pct = disk_used_pct(),
		cpu_temp_c = cpu_temp_c(),

		vm_r = vm.r,
		vm_si = vm.si,
		vm_so = vm.so,
		vm_wa = vm.wa,
		vm_us = vm.us,
		vm_sy = vm.sy,
		vm_id = vm.id,
		vm_bi = vm.bi,
		vm_bo = vm.bo,

		notes = nil,
	}

	insert_tick(db, row)
	db:close()
end

main()
