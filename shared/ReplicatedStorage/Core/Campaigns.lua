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

-- TODO: assert type on this
return {
	{
		Name = "Campaign A",
		Image = "rbxassetid://2278464",
		Difficulties = {
			{
				MinLevel = 1,
				Style = Easy,
				XP = 600,
				ZombieSpawnRate = 0.4,

				BossStats = {
					Health = 750,
					Speed = 18,
					Damage = 50,
				},
			},

			{
				MinLevel = 6,
				Style = Medium,
				XP = 1300,
				ZombieSpawnRate = 0.65,

				BossStats = {
					Health = 1400,
					Speed = 18.5,
					Damage = 120,
				},
			},

			{
				MinLevel = 12,
				Style = Hard,
				XP = 3000,
				ZombieSpawnRate = 0.75,

				BossStats = {
					Health = 2800,
					Speed = 19,
					Damage = 280,
				},
			},

			{
				MinLevel = 18,
				Style = VeryHard,
				XP = 4800,
				ZombieSpawnRate = 0.9,

				BossStats = {
					Health = 10000,
					Speed = 19.2,
					Damage = 650,
				},
			},

			{
				MinLevel = 24,
				Style = Extreme,
				XP = 10000,
				ZombieSpawnRate = 1,

				BossStats = {
					Health = 25000,
					Speed = 19.6,
					Damage = 1800,
				},
			},
		},
	},
}
