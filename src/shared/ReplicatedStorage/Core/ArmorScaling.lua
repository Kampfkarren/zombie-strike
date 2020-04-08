local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LinearThenLogarithmic = require(ReplicatedStorage.Core.LinearThenLogarithmic)

local ArmorScaling = {}

local BASE = 30
local FINAL = 425
local MULTIPLIER = 15

local REGEN_PERCENT = 0.1

local MULTIPLIERS = {
	1,
	1.05,
	1.1,
	1.15,
	1.23,
}

function ArmorScaling.ArmorHealth(level, rarity)
	return math.floor(LinearThenLogarithmic(BASE, FINAL, MULTIPLIER)(level) * MULTIPLIERS[rarity])
end

function ArmorScaling.ArmorRegen(level)
	return math.floor(ArmorScaling.ArmorHealth(level, 1) * REGEN_PERCENT)
end

ArmorScaling.HelmetHealth = ArmorScaling.ArmorHealth

return ArmorScaling
