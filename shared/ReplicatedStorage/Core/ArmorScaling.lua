local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Libraries.Data)

local ArmorScaling = {}

local ARMOR_BASE = 25
local HELMET_BASE = 15

local ARMOR_SCALE = 1.15
local HELMET_SCALE = 1.15

local MULTIPLIERS = {
	1,
	1.2,
	1.4,
	1.6,
	2.1
}

function ArmorScaling.ArmorHealth(level, rarity)
	return math.floor((ARMOR_BASE * ARMOR_SCALE ^ (level - 1)) * MULTIPLIERS[rarity])
end

function ArmorScaling.HelmetHealth(level, rarity)
	return math.floor((HELMET_BASE * HELMET_SCALE ^ (level - 1)) * MULTIPLIERS[rarity])
end

function ArmorScaling.Model(_, rarity)
	-- Technical debt if this guarantee is no longer true
	return ((Data.GetDungeonData("Campaign") - 1) * 5) + rarity
end

return ArmorScaling
