local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.Vendor.t)

local Easy = {
	Name = "Easy",
	Color = Color3.fromRGB(76, 209, 55),
}

local Medium = {
	Name = "Medium",
	Color = Color3.fromRGB(251, 197, 49),
}

local Hard = {
	Name = "Hard",
	Color = Color3.fromRGB(232, 65, 24),
}

local VeryHard = {
	Name = "Very Hard",
	Color = Color3.fromRGB(30, 55, 153),
}

local Extreme = {
	Name = "Extreme",
	Color = Color3.fromRGB(109, 35, 35),
}

local Insane = {
	Name = "Insane",
	Color = Color3.fromRGB(141, 30, 30),
}

local function range(start, finish)
	local range = {}

	for number = start, finish do
		table.insert(range, number)
	end

	return range
end

local function classicGuns(loot)
	local models = {
		Common = { 1 },
		Uncommon = { 2 },
		Rare = { 3 },
		Epic = { 4 },
		Legendary = { 5 },
	}

	local total = {
		Pistol = models,
		Rifle = models,
		SMG = models,
		Shotgun = models,
		Sniper = models,
	}

	for key, value in pairs(loot) do
		total[key] = value
	end

	return total
end

local lootRewardType = t.strictInterface({
	Common = t.array(t.number),
	Uncommon = t.array(t.number),
	Rare = t.array(t.number),
	Epic = t.array(t.number),
	Legendary = t.array(t.number),
})

local campaignsType = t.array(t.strictInterface({
	Name = t.string,
	Image = t.string,
	ZombieTypes = t.map(t.string, t.numberMin(1)),
	LoadingColor = t.Color3,

	Difficulties = t.array(t.strictInterface({
		MinLevel = t.numberMin(1),
		Style = t.strictInterface({
			Name = t.string,
			Color = t.Color3,
		}),

		Gold = t.numberMin(1),
		Rooms = t.numberMin(1),
		XP = t.numberMin(1),
		ZombieSpawnRate = t.numberConstrained(0, 1),

		BossStats = t.strictInterface({
			Health = t.numberMin(1),
		}),
	})),

	Loot = t.strictInterface({
		Armor = lootRewardType,
		Helmet = lootRewardType,

		Pistol = lootRewardType,
		Rifle = lootRewardType,
		SMG = lootRewardType,
		Shotgun = lootRewardType,
		Sniper = lootRewardType,
	}),

	Stats = t.map(t.string, t.map(t.string, t.strictInterface({
		Base = t.number,
		Scale = t.number,
	}))),

	AIAggroRange = t.number,
	CompletionBadge = t.number,
}))

local Campaigns = {
	{
		Name = "The Retro City",
		Image = "rbxassetid://4435346700",
		ZombieTypes = {
			Common = 3,
			Fast = 1,
			Strong = 1,
			Bomber = 1,
		},
		LoadingColor = Color3.fromRGB(253, 166, 255),

		Difficulties = {
			{
				MinLevel = 1,
				Style = Easy,

				Gold = 50,
				Rooms = 4,
				XP = 600,
				ZombieSpawnRate = 0.5,

				BossStats = {
					Health = 1350,
				},
			},

			{
				MinLevel = 6,
				Style = Medium,

				Gold = 120,
				Rooms = 7,
				XP = 1500,
				ZombieSpawnRate = 0.65,

				BossStats = {
					Health = 2520,
				},
			},

			{
				MinLevel = 12,
				Style = Hard,

				Gold = 370,
				Rooms = 10,
				XP = 3000,
				ZombieSpawnRate = 0.75,

				BossStats = {
					Health = 5040,
				},
			},

			{
				MinLevel = 18,
				Style = VeryHard,

				Gold = 800,
				Rooms = 12,
				XP = 7000,
				ZombieSpawnRate = 0.9,

				BossStats = {
					Health = 15000,
				},
			},

			{
				MinLevel = 24,
				Style = Extreme,

				Gold = 1900,
				Rooms = 13,
				XP = 14000,
				ZombieSpawnRate = 1,

				BossStats = {
					Health = 40000,
				},
			},
		},

		Loot = classicGuns({
			Armor = {
				Common = range(1, 7),
				Uncommon = range(8, 13),
				Rare = { 14 },
				Epic = { 15 },
				Legendary = { 16 },
			},

			Helmet = {
				Common = { 1 },
				Uncommon = { 2 },
				Rare = { 3 },
				Epic = { 4 },
				Legendary = { 5 },
			},
		}),

		Stats = {
			Common = {
				Health = {
					Base = 49,
					Scale = 1.154,
				},

				Speed = {
					Base = 13.5,
					Scale = 1.01,
				},

				Damage = {
					Base = 17.5,
					Scale = 1.15,
				},
			},

			Fast = {
				Health = {
					Base = 55,
					Scale = 1.154,
				},

				Speed = {
					Base = 19.5,
					Scale = 1.01,
				},

				Damage = {
					Base = 20,
					Scale = 1.15,
				},
			},

			Strong = {
				Damage = {
					Base = 33,
					Scale = 1.15,
				},

				Health = {
					Base = 113.75,
					Scale = 1.154,
				},

				Speed = {
					Base = 12.5,
					Scale = 1.01,
				},
			},

			Bomber = {
				Damage = {
					Base = 33,
					Scale = 1.15,
				},

				Health = {
					Base = 25,
					Scale = 1.154,
				},

				Speed = {
					Base = 22,
					Scale = 1,
				},

				Delay = {
					Base = 1,
					Scale = 0.99,
				},
			},
		},

		AIAggroRange = 180,
		CompletionBadge = 2124495354,
	},

	{
		Name = "The Factory",
		Image = "rbxassetid://69612219",
		ZombieTypes = {
			Common = 3,
			Fast = 1,
			Turret = 1,
			AoE = 1,
		},
		LoadingColor = Color3.fromRGB(206, 206, 206),

		Difficulties = {
			{
				MinLevel = 30,
				Style = Easy,

				Gold = 2500,
				Rooms = 4,
				XP = 21750,
				ZombieSpawnRate = 0.65,

				BossStats = {
					Health = 131250,
				}
			},

			{
				MinLevel = 36,
				Style = Medium,

				Gold = 4000,
				Rooms = 7,
				XP = 35000,
				ZombieSpawnRate = 0.75,

				BossStats = {
					Health = 467500,
				}
			},

			{
				MinLevel = 42,
				Style = Hard,

				Gold = 20000,
				Rooms = 8,
				XP = 125000,
				ZombieSpawnRate = 0.85,

				BossStats = {
					Health = 750000,
				}
			},

			{
				MinLevel = 48,
				Style = VeryHard,

				Gold = 50000,
				Rooms = 10,
				XP = 300000,
				ZombieSpawnRate = 0.9,

				BossStats = {
					Health = 3750000,
				}
			},

			{
				MinLevel = 54,
				Style = Extreme,

				Gold = 120000,
				Rooms = 12,
				XP = 845000,
				ZombieSpawnRate = 1,

				BossStats = {
					Health = 6250000,
				}
			},
		},

		Loot = classicGuns({
			Armor = {
				Common = { 17 },
				Uncommon = { 18 },
				Rare = { 19 },
				Epic = { 20 },
				Legendary = { 21 },
			},

			Helmet = {
				Common = { 6 },
				Uncommon = { 7 },
				Rare = { 8 },
				Epic = { 9 },
				Legendary = { 10 },
			},
		}),

		Stats = {
			Common = {
				Health = {
					Base = 3500,
					Scale = 1.135,
				},

				Speed = {
					Base = 17,
					Scale = 1,
				},

				Damage = {
					Base = 1800,
					Scale = 1.125,
				},
			},

			Fast = {
				Health = {
					Base = 2500,
					Scale = 1.135,
				},

				Speed = {
					Base = 20,
					Scale = 1,
				},

				Damage = {
					Base = 1000,
					Scale = 1.125,
				},
			},

			Turret = {
				Damage = {
					Base = 275,
					Scale = 1.167,
				},

				Health = {
					Base = 2800,
					Scale = 1.125,
				},

				RateOfFire = {
					Base = 1,
					Scale = 1.015,
				},

				Speed = {
					Base = 5,
					Scale = 1,
				},
			},

			AoE = {
				Health = {
					Base = 5000,
					Scale = 1.145,
				},

				Speed = {
					Base = 16,
					Scale = 1.003,
				},

				Damage = {
					Base = 1800,
					Scale = 1.135,
				},

				Range = {
					Base = 25,
					Scale = 1,
				},
			},
		},

		AIAggroRange = 60,
		CompletionBadge = 2124495355,
	},

	{
		Name = "The Firelands",
		Image = "rbxassetid://15648392",
		ZombieTypes = {
			Common = 3,
			Fast = 1,
			AoE = 1,
		},
		LoadingColor = Color3.fromRGB(255, 121, 32),

		Difficulties = {
			{
				MinLevel = 60,
				Style = Hard,

				Gold = 320000,
				Rooms = 6,
				XP = 1500000,
				ZombieSpawnRate = 0.65,

				BossStats = {
					Health = 15000000,
				},
			},

			{
				MinLevel = 64,
				Style = VeryHard,

				Gold = 640000,
				Rooms = 8,
				XP = 1860000,
				ZombieSpawnRate = 0.75,

				BossStats = {
					Health = 27000000,
				},
			},

			{
				MinLevel = 68,
				Style = Extreme,

				Gold = 1280000,
				Rooms = 10,
				XP = 2700000,
				ZombieSpawnRate = 0.85,

				BossStats = {
					Health = 54000000,
				},
			},

			{
				MinLevel = 72,
				Style = Insane,

				Gold = 2560000,
				Rooms = 12,
				XP = 2700000,
				ZombieSpawnRate = 1,

				BossStats = {
					Health = 108000000,
				},
			},
		},

		Loot = classicGuns({
			Armor = {
				Common = { 22 },
				Uncommon = { 23 },
				Rare = { 24 },
				Epic = { 25 },
				Legendary = { 26 },
			},

			Helmet = {
				Common = { 11 },
				Uncommon = { 12 },
				Rare = { 13 },
				Epic = { 14 },
				Legendary = { 15 },
			},
		}),

		Stats = {
			Common = {
				Health = {
					Base = 200000,
					Scale = 1.19,
				},

				Speed = {
					Base = 17,
					Scale = 1.005,
				},

				Damage = {
					Base = 68000,
					Scale = 1.18,
				},
			},

			Fast = {
				Health = {
					Base = 140000,
					Scale = 1.19,
				},

				Speed = {
					Base = 23,
					Scale = 1.005,
				},

				Damage = {
					Base = 42000,
					Scale = 1.18,
				},
			},

			AoE = {
				Health = {
					Base = 352000,
					Scale = 1.19,
				},

				Speed = {
					Base = 16.5,
					Scale = 1,
				},

				Damage = {
					Base = 90000,
					Scale = 1.18,
				},

				Range = {
					Base = 25,
					Scale = 1,
				},
			},
		},

		AIAggroRange = 60,
		CompletionBadge = 2124495356,
	},
}

assert(campaignsType(Campaigns))

return Campaigns
