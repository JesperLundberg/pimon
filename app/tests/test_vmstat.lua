-- Run from the app/ directory: luajit tests/test_vmstat.lua
package.path = "lua/?.lua;" .. package.path

local vmstat = require("pimon_vmstat")

local function eq(a, b, msg)
	if a ~= b then
		error(string.format("%s: expected %s, got %s", msg, tostring(b), tostring(a)), 2)
	end
end

-- Full 17-column line
local v = vmstat.parse_line(" 2  1      0 812340  45120 523000    3    4    10    20  150  300  12   5  80   3   0")
eq(v.r, 2, "r")
eq(v.b, 1, "b")
eq(v.si, 3, "si")
eq(v.so, 4, "so")
eq(v.bi, 10, "bi")
eq(v.bo, 20, "bo")
eq(v.us, 12, "us")
eq(v.sy, 5, "sy")
eq(v.id, 80, "id")
eq(v.wa, 3, "wa")

-- 15 columns: wa missing, defaults to 0
v = vmstat.parse_line("1 0 0 1 2 3 0 0 0 0 0 0 10 5 85")
eq(v.id, 85, "id (short)")
eq(v.wa, 0, "wa default")

-- Too short is an error
local ok = pcall(vmstat.parse_line, "1 2 3")
eq(ok, false, "short line errors")

-- Empty output is an error, not a crash on nil
ok = pcall(vmstat.parse_line, "")
eq(ok, false, "empty line errors")

print("all vmstat tests passed")
