#!/usr/bin/env luajit
-- pimon_rotate.lua
-- Export rows older than RETENTION_DAYS to a CSV in ARCHIVE_DIR, then delete
-- them so the tmpfs-backed database stays bounded.

local sqlite3 = require("lsqlite3")
local config = require("pimon_config")
local utils = require("pimon_utils")

local function csv_field(v)
	if v == nil then
		return ""
	end
	local s = tostring(v)
	if s:find('[,"\n]') then
		s = '"' .. s:gsub('"', '""') .. '"'
	end
	return s
end

local function main()
	utils.ensure_dir(config.ARCHIVE_DIR)
	local db = utils.open_db(config.DB_PATH)

	local cutoff = ("-%d days"):format(config.RETENTION_DAYS)
	local archive_path = ("%s/pimon_%s.csv"):format(config.ARCHIVE_DIR, os.date("!%Y%m%d"))

	local stmt = assert(db:prepare("SELECT * FROM pi_tick WHERE ts_utc < datetime('now', ?) ORDER BY id;"))
	stmt:bind_values(cutoff)

	local names = stmt:get_names()
	local lines = { table.concat(names, ",") }
	for row in stmt:rows() do
		local fields = {}
		for i = 1, #names do
			fields[i] = csv_field(row[i])
		end
		lines[#lines + 1] = table.concat(fields, ",")
	end
	stmt:finalize()

	if #lines == 1 then
		db:close()
		return
	end

	-- Append, so a second run on the same day does not clobber earlier output.
	-- The header is only written when the file is new.
	local existing = io.open(archive_path, "r")
	if existing then
		existing:close()
		table.remove(lines, 1)
	end
	local f = assert(io.open(archive_path, "a"))
	assert(f:write(table.concat(lines, "\n"), "\n"))
	assert(f:close())

	-- Only delete after the archive has been written successfully.
	local del = assert(db:prepare("DELETE FROM pi_tick WHERE ts_utc < datetime('now', ?);"))
	del:bind_values(cutoff)
	local rc = del:step()
	del:finalize()
	assert(rc == sqlite3.DONE, "delete failed: " .. db:errmsg())

	db:exec("VACUUM;")
	db:close()
end

main()
