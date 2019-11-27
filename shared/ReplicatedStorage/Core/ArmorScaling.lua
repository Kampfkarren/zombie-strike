local ArmorScaling = {}

local ARMOR_BASE = 32
local ARMOR_SCALE = 1.15

local HELMET_BASE = 24
local HELMET_SCALE = 1.15

local REGEN_BASE = 1.4
local REGEN_SCALE = 1.15

local MULTIPLIERS = {
	1,
	1.22,
	1.44,
	1.66,
	2.2,
}

function ArmorScaling.ArmorHealth(level, rarity)
	return math.floor((ARMOR_BASE * ARMOR_SCALE ^ (level - 1)) * MULTIPLIERS[rarity])
end

function ArmorScaling.ArmorRegen(level)
	return math.floor(REGEN_BASE * REGEN_SCALE ^ (level - 1))
end

function ArmorScaling.HelmetHealth(level, rarity)
	return math.floor((HELMET_BASE * HELMET_SCALE ^ (level - 1)) * MULTIPLIERS[rarity])
end

return ArmorScaling
