#!/usr/bin/env luajit

local json = require("dkjson")
local config = require("pimon_config")
local utils = require("pimon_utils")

local DB_PATH = config.DB_PATH
local JSON_PATH = config.JSON_PATH

local function open_db()
	return utils.open_db(DB_PATH)
end

local function get_latest(db)
	local row
	for r in
		db:nrows([[
    SELECT
      ts_utc,
      strftime('%s', ts_utc) AS ts_epoch,
      load1,
      mem_total_kb,
      mem_avail_kb,
      disk_used_pct,
      cpu_temp_c
    FROM pi_tick
    ORDER BY id DESC
    LIMIT 1;
  ]])
	do
		row = r
	end
	return row
end

local function write_json(obj)
	utils.ensure_dir("/var/www/html/pimon")
	local f = assert(io.open(JSON_PATH, "w"))
	f:write(json.encode(obj, { indent = true }))
	f:close()
end

local function main()
	local db = open_db()
	local latest = get_latest(db)
	db:close()

	if not latest then
		write_json({ has_data = false })
		return
	end

	write_json({
		has_data = true,
		ts_utc = latest.ts_utc,
		ts_epoch = tonumber(latest.ts_epoch),
		load1 = tonumber(latest.load1),
		mem_total_kb = tonumber(latest.mem_total_kb),
		mem_avail_kb = tonumber(latest.mem_avail_kb),
		disk_used_pct = tonumber(latest.disk_used_pct),
		cpu_temp_c = latest.cpu_temp_c and tonumber(latest.cpu_temp_c) or nil,
	})
end

main()
