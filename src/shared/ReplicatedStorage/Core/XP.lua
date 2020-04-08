local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LinearThenLogarithmic = require(ReplicatedStorage.Core.LinearThenLogarithmic)

local XP = {}

local BASE_HEALTH = 100
local BASE_MAX_XP = 100

local HEALTH_AT_MAX = 1900
local HEALTH_MULTIPLIER = 100

local XP_MULTIPLIER = 1.2

local function round(n)
	return math.floor(n + 0.5)
end

XP.HealthForLevel = LinearThenLogarithmic(BASE_HEALTH, HEALTH_AT_MAX, HEALTH_MULTIPLIER)

function XP.XPNeededForNextLevel(level)
	return round(BASE_MAX_XP * XP_MULTIPLIER ^ (level - 1))
end

return XP
