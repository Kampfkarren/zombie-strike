local LEVEL_CAP = 70

local function LinearThenLogarithmic(base, final, multiplier)
	return function(level)
		if level > LEVEL_CAP then
			return multiplier * math.log10(level - LEVEL_CAP + 1) + final
		else
			return ((final - base) / (LEVEL_CAP - 1))
				* level
				+ (base - ((final - base) / (LEVEL_CAP - 1)))
		end
	end
end

return LinearThenLogarithmic
