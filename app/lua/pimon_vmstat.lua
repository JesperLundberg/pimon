local M = {}

-- Parse one data line of procps `vmstat` output.
-- Columns: r b swpd free buff cache si so bi bo in cs us sy id wa st
function M.parse_line(line)
	local cols = {}
	for tok in (line or ""):gmatch("%S+") do
		cols[#cols + 1] = tok
	end

	-- Need at least through "id" (15). "wa" (16) and "st" (17) may be missing.
	if #cols < 15 then
		error("vmstat output too short: " .. tostring(line), 0)
	end

	return {
		r = tonumber(cols[1]) or 0,
		b = tonumber(cols[2]) or 0,

		-- Swap (kB/s)
		si = tonumber(cols[7]) or 0,
		so = tonumber(cols[8]) or 0,

		-- Block IO (blocks/s; depends on system block size)
		bi = tonumber(cols[9]) or 0,
		bo = tonumber(cols[10]) or 0,

		-- CPU (%)
		us = tonumber(cols[13]) or 0,
		sy = tonumber(cols[14]) or 0,
		id = tonumber(cols[15]) or 0,
		wa = tonumber(cols[16]) or 0,
	}
end

return M
