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
	}))
}))

local Campaigns = {
	{
		Name = "Campaign A",
		Image = "rbxassetid://2278464",
		ZombieTypes = {
			-- Turret = 3,
			Common = 7,
		},

		Difficulties = {
			{
				MinLevel = 1,
				Style = Easy,

				Gold = 50,
				Rooms = 8,
				XP = 600,
				ZombieSpawnRate = 0.4,

				BossStats = {
					Health = 750,
				},
			},

			{
				MinLevel = 6,
				Style = Medium,

				Gold = 120,
				Rooms = 10,
				XP = 1300,
				ZombieSpawnRate = 0.65,

				BossStats = {
					Health = 1400,
				},
			},

			{
				MinLevel = 12,
				Style = Hard,

				Gold = 370,
				Rooms = 12,
				XP = 3000,
				ZombieSpawnRate = 0.75,

				BossStats = {
					Health = 2800,
				},
			},

			{
				MinLevel = 18,
				Style = VeryHard,

				Gold = 800,
				Rooms = 14,
				XP = 4800,
				ZombieSpawnRate = 0.9,

				BossStats = {
					Health = 10000,
				},
			},

			{
				MinLevel = 24,
				Style = Extreme,

				Gold = 1900,
				Rooms = 16,
				XP = 10000,
				ZombieSpawnRate = 1,

				BossStats = {
					Health = 25000,
				},
			},
		},
	},
}

assert(campaignsType(Campaigns))

return Campaigns
