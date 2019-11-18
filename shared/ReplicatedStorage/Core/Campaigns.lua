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
}))

local Campaigns = {
	{
		Name = "The City",
		Image = "rbxassetid://2278464",
		ZombieTypes = {
			Common = 3,
			Fast = 1,
			Strong = 1,
			Turret = 1,
		},

		Difficulties = {
			{
				MinLevel = 1,
				Style = Easy,

				Gold = 50,
				Rooms = 4,
				XP = 600,
				ZombieSpawnRate = 0.4,

				BossStats = {
					Health = 2250,
				},
			},

			{
				MinLevel = 6,
				Style = Medium,

				Gold = 120,
				Rooms = 7,
				XP = 1300,
				ZombieSpawnRate = 0.65,

				BossStats = {
					Health = 4200,
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
					Health = 8400,
				},
			},

			{
				MinLevel = 18,
				Style = VeryHard,

				Gold = 800,
				Rooms = 12,
				XP = 4800,
				ZombieSpawnRate = 0.9,

				BossStats = {
					Health = 30000,
				},
			},

			{
				MinLevel = 24,
				Style = Extreme,

				Gold = 1900,
				Rooms = 13,
				XP = 10000,
				ZombieSpawnRate = 1,

				BossStats = {
					Health = 75000,
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
					Base = 70,
					Scale = 1.154,
				},

				Speed = {
					Base = 14.5,
					Scale = 1.01,
				},

				Damage = {
					Base = 25,
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

			Turret = {
				Damage = {
					Base = 5,
					Scale = 1.15,
				},

				Health = {
					Base = 45,
					Scale = 1.154,
				},

				RateOfFire = {
					Base = 0.5,
					Scale = 1.09,
				},

				Speed = {
					Base = 5,
					Scale = 1,
				},
			},
		},
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

		Difficulties = {
			{
				MinLevel = 30,
				Style = Easy,

				Gold = 2500,
				Rooms = 4,
				XP = 19000,
				ZombieSpawnRate = 0.65,

				BossStats = {
					Health = 52500,
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
					Health = 187000,
				}
			},

			{
				MinLevel = 42,
				Style = Hard,

				Gold = 20000,
				Rooms = 10,
				XP = 58000,
				ZombieSpawnRate = 0.85,

				BossStats = {
					Health = 500000,
				}
			},

			{
				MinLevel = 48,
				Style = VeryHard,

				Gold = 50000,
				Rooms = 12,
				XP = 180000,
				ZombieSpawnRate = 0.9,

				BossStats = {
					Health = 1500000,
				}
			},

			{
				MinLevel = 54,
				Style = Extreme,

				Gold = 120000,
				Rooms = 13,
				XP = 500000,
				ZombieSpawnRate = 1,

				BossStats = {
					Health = 5000000,
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
					Scale = 1.19,
				},

				Speed = {
					Base = 17,
					Scale = 1,
				},

				Damage = {
					Base = 1800,
					Scale = 1.18,
				},
			},

			Fast = {
				Health = {
					Base = 2500,
					Scale = 1.19,
				},

				Speed = {
					Base = 20,
					Scale = 1,
				},

				Damage = {
					Base = 1000,
					Scale = 1.18,
				},
			},

			Turret = {
				Damage = {
					Base = 650,
					Scale = 1.167,
				},

				Health = {
					Base = 2800,
					Scale = 1.205,
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
					Scale = 1.205,
				},

				Speed = {
					Base = 16,
					Scale = 1.005,
				},

				Damage = {
					Base = 2200,
					Scale = 1.195,
				},

				Range = {
					Base = 25,
					Scale = 1,
				}
			},
		},
	},
}

assert(campaignsType(Campaigns))

return Campaigns
