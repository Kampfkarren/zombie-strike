local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttachmentsConstants = require(ReplicatedStorage.Core.AttachmentsConstants)
local LinearThenLogarithmic = require(ReplicatedStorage.Core.LinearThenLogarithmic)
local Upgrades = require(ReplicatedStorage.Core.Upgrades)

local GunScaling = {}

local LEVEL_CAP = 70

local function constant(value)
	return function()
		return value
	end
end

local function linear(base, slope)
	return function(level)
		level = math.min(level, LEVEL_CAP)
		return slope * (level - 1) + base
	end
end

local Bases = {}

Bases.Pistol = {
	Type = "Gun",
	Size = "Light",

	Recoil = 25,
	Range = 500,
	ShotSize = 1,
	Spread = 2,
	Zoom = 20,
	ReloadTime = 0.75,
	FireMode = "Auto",
	Dropoff = 3,
	ScaleBuff = 1.15,
}

Bases.Rifle = {
	Type = "Gun",
	Size = "Medium",

	Recoil = 10,
	Range = 700,
	ShotSize = 1,
	Spread = 2,
	Zoom = 20,
	ReloadTime = 1.25,
	FireMode = "Auto",
	Dropoff = 3,
	ScaleBuff = 1.18,
}

Bases.Shotgun = {
	Type = "Gun",
	Size = "Shotgun",

	Recoil = 30,
	Range = 150,
	Spread = 8,
	Zoom = 10,
	ReloadTime = 1.8,
	FireMode = "Auto",
	Dropoff = 3,
	Reticle = "Shotgun",
	ScaleBuff = 1.15,
}

Bases.SMG = {
	Type = "Gun",
	Size = "Light",

	Recoil = 12,
	Range = 500,
	ShotSize = 1,
	Spread = 3,
	Zoom = 20,
	ReloadTime = 1,
	FireMode = "Auto",
	Dropoff = 3,
	ScaleBuff = 1.15,
}

Bases.Sniper = {
	Type = "Gun",
	Size = "Heavy",

	Recoil = 30,
	Range = 1300,
	ShotSize = 1,
	Spread = 0,
	Zoom = 35,
	ReloadTime = 1.75,
	FireMode = "Auto",
	Dropoff = 5,
	ScaleBuff = 0.95,
}

Bases.Crystal = {
	Type = "Gun",
	Size = "Light",

	Recoil = 10,
	Range = 1300,
	ShotSize = 1,
	Spread = 2,
	Zoom = 20,
	ReloadTime = 0,
	FireMode = "Auto",
	Dropoff = 3,
	ScaleBuff = 1,
}

local Types = {
	Pistol = {
		CritChance = linear(6, 0.10),
		CritDamage = linear(6, 0.05),
		Damage = LinearThenLogarithmic(12.5, 165, 10),
		FireRate = linear(5, 0.01),
		Magazine = linear(10, 0.04),
	},

	Rifle = {
		CritChance = linear(6, 0.05),
		CritDamage = linear(6, 0.02),
		Damage = LinearThenLogarithmic(6.6, 68, 10),
		FireRate = linear(11, 0.02),
		Magazine = linear(62, 0.2),
	},

	SMG = {
		CritChance = linear(4, 0.05),
		CritDamage = linear(6, 0.01),
		Damage = LinearThenLogarithmic(6.6, 78, 5),
		FireRate = linear(25, 0.2),
		Magazine = linear(24, 0.1),
	},

	Shotgun = {
		CritChance = linear(1.5, 0.02),
		CritDamage = linear(2, 0.025),
		Damage = LinearThenLogarithmic(11, 164, 10),
		FireRate = linear(3, 0.008),
		Magazine = linear(6, 0.015),
		ShotSize = constant(5),
	},

	Sniper = {
		CritChance = linear(15, 0.035),
		CritDamage = linear(3, 0.020),
		Damage = LinearThenLogarithmic(75, 700, 25),
		FireRate = linear(1.8, 0.0025),
		Magazine = linear(7, 0.05),
	},

	Crystal = {
		CritChance = constant(1),
		CritDamage = constant(5),
		Damage = LinearThenLogarithmic(13, 220, 10),
		FireRate = linear(5, 0.02),
		Magazine = constant(1),
	},
}

local RarityMultipliers = {
	-- Common
	{
		CritChance = 1,
		CritDamage = 1,
		Damage = 1,
		FireRate = 1,
		Magazine = 1,
	},

	-- Uncommon
	{
		CritChance = 1.1,
		CritDamage = 1.05,
		Damage = 1.15,
		FireRate = 1.1,
		Magazine = 1.1,
	},

	-- Rare
	{
		CritChance = 1.2,
		CritDamage = 1.1,
		Damage = 1.3,
		FireRate = 1.2,
		Magazine = 1.2,
	},

	-- Epic
	{
		CritChance = 1.3,
		CritDamage = 1.15,
		Damage = 1.45,
		FireRate = 1.3,
		Magazine = 1.3,
	},

	-- Legendary
	{
		CritChance = 1.4,
		CritDamage = 1.2,
		Damage = 1.6,
		FireRate = 1.4,
		Magazine = 1.4,
	},
}

local function round(n)
	return math.floor(n + 0.5)
end

function GunScaling.BaseStats(type, level, rarity)
	local gunType = assert(Types[type])
	local rarityMultipliers = assert(RarityMultipliers[rarity])

	local stats = {}

	for statName, getStat in pairs(gunType) do
		stats[statName] = getStat(level) * (rarityMultipliers[statName] or 1)

		if statName == "Damage" or statName == "Magazine" then
			stats[statName] = round(stats[statName])
		elseif statName == "CritChance" then
			stats[statName] = stats[statName] / 100
		end
	end

	return stats
end

function GunScaling.StatsFor(item)
	local stats = GunScaling.BaseStats(item.Type, item.Level, item.Rarity)

	for baseKey, baseValue in pairs(Bases[item.Type]) do
		stats[baseKey] = baseValue
	end

	local attachment = item.Attachment
	if attachment then
		if attachment.Type == "Magazine" then
			stats.Magazine = math.ceil(stats.Magazine * (1 + AttachmentsConstants.Magazine[attachment.Rarity] / 100))
		elseif attachment.Type == "Laser" then
			stats.CritChance = stats.CritChance * (1 + AttachmentsConstants.LaserSightCritChance[attachment.Rarity] / 100)
			stats.Recoil = stats.Recoil * (1 + AttachmentsConstants.LaserSightRecoil[attachment.Rarity] / 100)
		elseif attachment.Type == "Silencer" then
			stats.Damage = math.ceil(stats.Damage * (1 + AttachmentsConstants.SilencerDamage[attachment.Rarity] / 100))
		end
	end

	stats.Damage = stats.Damage + Upgrades.GetDamageBuff(stats.Damage, item.Upgrades or 0)

	return stats
end

function GunScaling.RandomClassicType()
	local rng = Random.new()
	local types = {}

	for type in pairs(Types) do
		if type ~= "Crystal" then
			table.insert(types, type)
		end
	end

	table.sort(types) -- pairs is not documented to be deterministic

	return types[rng:NextInteger(1, #types)]
end

return GunScaling
