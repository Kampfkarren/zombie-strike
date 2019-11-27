local XP = {}

local BASE_HEALTH = 100
local BASE_MAX_XP = 100

local HEALTH_MULTIPLIER = 1.15
local XP_MULTIPLIER = 1.2

local function round(n)
	return math.floor(n + 0.5)
end

function XP.HealthForLevel(level)
	return round(BASE_HEALTH * HEALTH_MULTIPLIER ^ (level - 1))
end

function XP.XPNeededForNextLevel(level)
	return round(BASE_MAX_XP * XP_MULTIPLIER ^ (level - 1))
end

return XP
