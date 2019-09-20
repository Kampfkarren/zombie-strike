local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local GunScaling = {}

local Types = {
	Pistol = {
		Base = {
			CritChance = 0.08,
			Damage = 20,
			FireRate = 5,
			Magazine = 9,
		},

		Scale = {
			CritChance = 1.01,
			Damage = 1.12,
			FireRate = 1.01,
			Magazine = 1.01,
		},
	},

	Rifle = {
		Base = {
			CritChance = 0.01,
			Damage = 12,
			FireRate = 10,
			Magazine = 24,
		},

		Scale = {
			CritChance = 1.01,
			Damage = 1.12,
			FireRate = 1.01,
			Magazine = 1.011,
		},
	},

	SMG = {
		Base = {
			CritChance = 0.03,
			Damage = 8,
			FireRate = 12,
			Magazine = 30,
		},

		Scale = {
			CritChance = 1.01,
			Damage = 1.12,
			FireRate = 1.01,
			Magazine = 1.011,
		},
	},

	Shotgun = {
		Base = {
			CritChance = 0.04,
			Damage = 8,
			FireRate = 2.5,
			Magazine = 6,
			PelletCount = 5,
		},

		Scale = {
			CritChance = 1.01,
			Damage = 1.12,
			FireRate = 1.01,
			Magazine = 1.011,
			PelletCount = 1.01,
		},
	},

	Sniper = {
		Base = {
			CritChance = 0.04,
			Damage = 30,
			FireRate = 1.5,
			Magazine = 6,
		},

		Scale = {
			CritChance = 1.25,
			Damage = 1.12,
			FireRate = 1.01,
			Magazine = 1.011,
		},
	},
}

local RarityMultipliers = {
	-- Common
	{
		CritChance = 1,
		Damage = 1,
		FireRate = 1,
		Magazine = 1,
	},

	-- Uncommon
	{
		CritChance = 1.1,
		Damage = 1.2,
		FireRate = 1.1,
		Magazine = 1.1,
	},

	-- Rare
	{
		CritChance = 1.25,
		Damage = 1.4,
		FireRate = 1.25,
		Magazine = 1.25,
	},

	-- Epic
	{
		CritChance = 1.35,
		Damage = 1.8,
		FireRate = 1.35,
		Magazine = 1.35,
	},

	-- Legendary
	{
		CritChance = 1.5,
		Damage = 2.5,
		FireRate = 1.5,
		Magazine = 1.5,
	},
}

local function round(n)
	return math.floor(n + 0.5)
end

function GunScaling.BaseStats(type, level, rarity)
	local gunType = assert(Types[type])
	local rarityMultipliers = assert(RarityMultipliers[rarity])

	local stats = {}

	for statName, stat in pairs(gunType.Base) do
		stats[statName] =
			(stat * gunType.Scale[statName] ^ (level - 1))
			* (rarityMultipliers[statName] or 1)

		if statName == "Damage" or statName == "Magazine" then
			stats[statName] = round(stats[statName])
		end
	end

	return stats
end

function GunScaling.RandomType()
	local types = {}
	for type in pairs(Types) do
		table.insert(types, type)
	end
	return types[math.random(#types)]
end

return GunScaling
