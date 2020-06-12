local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.Vendor.t)

local Easy = {
	Name = "Easy",
	Color = Color3.fromRGB(76, 209, 55),
	Gold = 250,
}

local Medium = {
	Name = "Medium",
	Color = Color3.fromRGB(251, 197, 49),
	Gold = 320,
}

local Hard = {
	Name = "Hard",
	Color = Color3.fromRGB(232, 65, 24),
	Gold = 340,
}

local VeryHard = {
	Name = "Very Hard",
	Color = Color3.fromRGB(30, 55, 153),
	Gold = 370,
}

local Extreme = {
	Name = "Extreme",
	Color = Color3.fromRGB(109, 35, 35),
	Gold = 420,
}

local TOWER_REACTION_TIME = table.create(5, 1)

local function range(start, finish)
	local range = {}

	for number = start, finish do
		table.insert(range, number)
	end

	return range
end

local function fullGuns(baseNumber, loot)
	local models = {
		Common = { baseNumber + 1 },
		Uncommon = { baseNumber + 2 },
		Rare = { baseNumber + 3 },
		Epic = { baseNumber + 4 },
		Legendary = { baseNumber + 5 },
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

local function classicGuns(loot)
	return fullGuns(0, loot)
end

local function classicGunsPatched(loot, patch)
	local guns = fullGuns(0, loot)
	for key, value in pairs(patch) do
		guns[key] = value
	end
	return guns
end

local function constant(number)
	return table.create(5, number)
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
	SpecialZombies = t.array(t.string),
	LoadingColor = t.Color3,
	LockedArena = t.optional(t.boolean),
	Scales = t.optional(t.boolean),
	TreasureDelayTime = t.optional(t.numberMin(0)),

	Difficulties = t.array(t.strictInterface({
		MinLevel = t.optional(t.numberMin(1)),
		TimesPlayed = t.optional(t.numberMin(0)),

		Style = t.interface({
			Name = t.string,
			Color = t.Color3,
		}),

		Gold = t.numberMin(1),
		Rooms = t.numberMin(1),
		XP = t.numberMin(1),
		ZombieSpawnRate = t.numberConstrained(0, 1),

		BossStats = t.optional(t.strictInterface({
			Health = t.optional(t.numberMin(1)),
		})),
	})),

	Loot = t.strictInterface({
		Armor = lootRewardType,
		Helmet = lootRewardType,

		Pistol = lootRewardType,
		Rifle = lootRewardType,
		SMG = lootRewardType,
		Shotgun = lootRewardType,
		Sniper = lootRewardType,
		Crystal = t.optional(lootRewardType),
	}),

	DropTable = t.optional(t.strictInterface({
		Crystal = t.optional(t.number),
	})),

	Stats = t.map(
		t.string,
		t.map(t.string, t.union(
			t.strictInterface({
				Base = t.number,
				Scale = t.number,
			}),

			t.map(t.number, t.number)
		))
	),

	AIAggroRange = t.number,
}))

local Campaigns = {
	{
		Name = "The Retro City",
		Image = "rbxassetid://4473244330",
		ZombieTypes = {
			Common = 3,
			Fast = 1,
			Strong = 1,
			Bomber = 1,
		},
		SpecialZombies = { "Shielder", "Splitter" },
		LoadingColor = Color3.fromRGB(253, 166, 255),

		Difficulties = {
			{
				MinLevel = 1,
				Style = Easy,

				Rooms = 4,
				XP = 600,
				ZombieSpawnRate = 0.5,

				BossStats = {
					Health = 2000,
				},
			},

			{
				MinLevel = 6,
				Style = Medium,

				Rooms = 6,
				XP = 1000,
				ZombieSpawnRate = 0.65,

				BossStats = {
					Health = 4000,
				},
			},

			{
				MinLevel = 32,
				Style = Hard,

				Rooms = 7,
				XP = 15000,
				ZombieSpawnRate = 0.75,

				BossStats = {
					Health = 34000,
				},
			},

			{
				MinLevel = 56,
				Style = VeryHard,

				Rooms = 8,
				XP = 500000,
				ZombieSpawnRate = 0.75,

				BossStats = {
					Health = 148000,
				},
			},

			{
				MinLevel = 78,
				Style = Extreme,

				Rooms = 9,
				XP = 25500000,
				ZombieSpawnRate = 0.75,

				BossStats = {
					Health = 220000,
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
				Health = { 50, 130, 550, 980, 2282 },
				Damage = { 25, 60, 145, 350, 620 },
				Speed = { 13, 13.5, 14, 14.1, 14.5 },
			},

			Strong = {
				Health = { 75, 195, 825, 1470, 3423 },
				Damage = { 37.5, 90, 217.5, 525, 930 },
				Speed = { 12, 12.5, 13, 13.1, 13.5 },
			},

			Fast = {
				Health = { 35, 91, 385, 686, 1600 },
				Damage = { 25, 60, 145, 350, 620 },
				Speed = { 14, 14.5, 15, 15.1, 15.5 },
			},

			Bomber = {
				Health = { 20, 51, 285, 486, 1100 },
				Damage = { 50, 110, 240, 700, 1200 },
				Speed = { 16, 16.5, 17, 17.1, 17.5 },
				Delay = constant(1),
			},

			Shielder = {
				Health = { 0, 325, 1320, 2205, 5500 },
				Damage = { 0, 90, 217.5, 525, 930 },
				Speed = { 0, 12.5, 13, 13.1, 13.5 },
				EnragedSpeed = { 0, 19, 20, 20, 21 },
			},

			Splitter = {
				Health = { 0, 0, 2500, 4000, 9000 },
				Damage = { 0, 0, 500, 800, 1300 },
				Speed = constant(11),
				BabiesSpawned = { 0, 0, 2, 2, 3 },
			},

			SplitterBaby = {
				Health = { 0, 0, 300, 400, 1000 },
				Damage = { 0, 0, 100, 250, 400 },
				Speed = { 0, 0, 17, 18, 20 },
				RespawnTime = { 0, 0, 8, 7, 6 },
			},
		},

		AIAggroRange = 180,
	},

	{
		Name = "The Factory",
		Image = "rbxassetid://4473244539",
		ZombieTypes = {
			Common = 3,
			Fast = 1,
			AoE = 1,
		},
		SpecialZombies = { "Gravity", "Taser" },
		LoadingColor = Color3.fromRGB(206, 206, 206),

		Difficulties = {
			{
				MinLevel = 15,
				Style = Easy,

				Rooms = 4,
				XP = 3000,
				ZombieSpawnRate = 0.65,
			},

			{
				MinLevel = 40,
				Style = Medium,

				Rooms = 6,
				XP = 65000,
				ZombieSpawnRate = 0.7,
			},

			{
				MinLevel = 64,
				Style = Hard,

				Rooms = 7,
				XP = 1500000,
				ZombieSpawnRate = 0.75,
			},

			{
				MinLevel = 86,
				Style = VeryHard,

				Rooms = 7,
				XP = 82000000,
				ZombieSpawnRate = 0.8,
			},

			{
				MinLevel = 106,
				Style = Extreme,

				Rooms = 7,
				XP = 1875000000,
				ZombieSpawnRate = 0.85,
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
				Health = { 250, 720, 1200, 2500, 2750 },
				Damage = { 29, 70, 160, 370, 680 },
				Speed = { 13, 13.5, 14, 14.1, 14.5 },
			},

			AoE = {
				Health = { 520, 1200, 1500, 2600, 3300 },
				Damage = { 100, 240, 700, 800, 950 },
				Speed = { 13, 13.2, 13.4, 13.5, 13.75 },
				Range = constant(25),
			},

			Fast = {
				Health = { 150, 500, 800, 2000, 2100 },
				Damage = { 20, 50, 130, 300, 550 },
				Speed = constant(16),
			},

			Gravity = {
				Health = { 1300, 2000, 2500, 3200, 4500 },
				Damage = { 29, 70, 160, 370, 680 },
				Speed = constant(4),
			},

			Taser = {
				Health = { 1800, 2500, 3400, 4800, 6000 },
				Damage = { 100, 240, 700, 800, 950 },
				Speed = constant(10),
				StunDuration = { 0.5, 0.6, 0.7, 0.7, 0.7 },
			},

			Boss = {
				Health = { 13000, 23000, 50000, 190000, 250000 },
				BaseSpinDamage = { 300, 400, 800, 1500, 2500 },
				BaseSpinSpeed = { 1, 1.05, 1.1, 1.13, 1.2 },
				FloorLaserDamage = { 250, 300, 700, 1300, 2000 },
				QuadLaserChargeTime = { 3, 2.8, 2.6, 2.5, 2.2 },
				QuadLaserDamage = { 300, 400, 800, 1500, 2500 },
				QuadLaserRateOfFire = { 6, 5, 5, 4, 3.5 },
				QuadLaserTime = { 1, 1.1, 1.2, 1.3, 1.4 },
			},
		},

		AIAggroRange = 60,
	},

	{
		Name = "The Firelands",
		Image = "rbxassetid://4473242430",
		ZombieTypes = {
			Common = 3,
			Fast = 1,
			AoE = 1,
		},
		SpecialZombies = { "Flamecaster", "Meteor" },
		LoadingColor = Color3.fromRGB(255, 121, 32),

		Difficulties = {
			{
				MinLevel = 20,
				Style = Easy,

				Rooms = 4,
				XP = 3500,
				ZombieSpawnRate = 0.65,
			},

			{
				MinLevel = 44,
				Style = Medium,

				Rooms = 6,
				XP = 120000,
				ZombieSpawnRate = 0.75,
			},

			{
				MinLevel = 68,
				Style = Hard,

				Rooms = 7,
				XP = 2500000,
				ZombieSpawnRate = 0.85,
			},

			{
				MinLevel = 90,
				Style = VeryHard,

				Rooms = 7,
				XP = 150000000,
				ZombieSpawnRate = 0.85,
			},

			{
				MinLevel = 110,
				Style = Extreme,

				Rooms = 7,
				XP = 3000000000,
				ZombieSpawnRate = 0.85,
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
				Health = { 300, 800, 1350, 2700, 3000 },
				Damage = { 40, 100, 200, 460, 700 },
				Speed = { 13, 13.5, 14, 14.1, 14.5 },
			},

			AoE = {
				Health = { 620, 1400, 1800, 3000, 3400 },
				Damage = { 110, 260, 750, 900, 1100 },
				Speed = { 13, 13.2, 13.4, 13.5, 13.75 },
				Range = constant(25),
			},

			Fast = {
				Health = { 200, 600, 1100, 2300, 2400 },
				Damage = { 30, 70, 140, 380, 620 },
				Speed = constant(17),
			},

			Flamecaster = {
				Health = { 900, 2100, 2500, 3500, 4200 },
				Damage = { 20, 50, 100, 200, 350 },
				Range = { 40, 50, 60, 70, 80 },
				Speed = constant(0),
			},

			Meteor = {
				Health = { 1400, 2600, 3200, 4000, 5000 },
				Damage = { 110, 260, 750, 900, 1100 },
				MeteorCooldown = { 4, 3, 3, 3, 2 },
				MeteorDamage = { 110, 260, 750, 900, 1100 },
				Speed = constant(14),
			},

			Boss = {
				Health = { 15000, 25000, 50000, 190000, 260000 },
				MassiveLaserDamage = { 600, 800, 1600, 3000, 5000 },
				MassiveLaserWindup = { 4, 3.6, 3.2, 2.8, 2.8 },
				SummonCount = { 3, 4, 5, 6, 6 },
				TriLaserCount = { 4, 5, 5, 6, 7 },
				TriLaserDamage = { 300, 400, 800, 1500, 2500 },
			},
		},

		AIAggroRange = 60,
	},

	{
		Name = "The Frostlands",
		Image = "rbxassetid://4494569889",
		ZombieTypes = {
			Common = 3,
			Fast = 1,
			Strong = 1,
			AoE = 1,
			Projectile = 1,
		},
		SpecialZombies = { "Blizzard", "MegaSnowball" },
		LoadingColor = Color3.new(1, 1, 1),

		Difficulties = {
			{
				MinLevel = 24,
				Style = Easy,

				Rooms = 4,
				XP = 6500,
				ZombieSpawnRate = 0.6,
			},

			{
				MinLevel = 48,
				Style = Medium,

				Rooms = 5,
				XP = 170000,
				ZombieSpawnRate = 0.7,
			},

			{
				MinLevel = 72,
				Style = Hard,

				Rooms = 6,
				XP = 2500000,
				ZombieSpawnRate = 0.8,
			},

			{
				MinLevel = 94,
				Style = VeryHard,

				Rooms = 6,
				XP = 290000000,
				ZombieSpawnRate = 0.8,
			},

			{
				MinLevel = 114,
				Style = Extreme,

				Rooms = 6,
				XP = 7000000000,
				ZombieSpawnRate = 0.8,
			},
		},

		Loot = fullGuns(5, {
			Armor = {
				Common = { 27 },
				Uncommon = { 28 },
				Rare = { 29 },
				Epic = { 30 },
				Legendary = { 31 },
			},

			Helmet = {
				Common = { 16 },
				Uncommon = { 17 },
				Rare = { 18 },
				Epic = { 19 },
				Legendary = { 20 },
			},
		}),

		Stats = {
			Common = {
				Health = { 350, 900, 1500, 3000, 3300 },
				Damage = { 60, 120, 240, 500, 750 },
				Speed = { 13, 13.5, 14, 14.1, 14.5 },
			},

			Strong = {
				Health = { 1600, 1800, 2250, 3300, 3850 },
				Damage = { 130, 300, 800, 990, 1300 },
				Speed = { 13, 13.2, 13.4, 13.5, 13.75 },
			},

			AoE = {
				Health = { 1600, 1800, 2250, 3300, 3850 },
				Damage = { 130, 300, 800, 990, 1300 },
				Speed = { 13, 13.2, 13.4, 13.5, 13.75 },
				Range = constant(25),
			},

			Fast = {
				Health = { 220, 700, 1200, 2500, 2900 },
				Damage = { 60, 120, 240, 500, 750 },
				Speed = constant(17.5),
			},

			Projectile = {
				Health = { 350, 900, 1500, 3000, 3300 },
				Damage = { 60, 120, 240, 500, 750 },
				Speed = { 13, 13.5, 14, 14.1, 14.5 },
			},

			Blizzard = {
				Health = { 4200, 4800, 5800, 7000, 8900 },
				Damage = { 130, 300, 800, 990, 1300 },
				Speed = constant(15),
			},

			MegaSnowball = {
				Health = { 4200, 4800, 5800, 7000, 8900 },
				Damage = { 130, 300, 800, 990, 1300 },
				SnowballDamage = { 250, 500, 1200, 1500, 1800 },
				Cooldown = { 4, 3, 3, 3, 2 },
				Speed = constant(15),
			},

			Boss = {
				Health = { 15000, 25000, 50000, 195000, 265000 },
				IcicleDamage = { 130, 300, 800, 990, 1300 },
				IcicleTimer = { 6, 7, 8, 9, 10 },
				SlamAttackDamage = { 250, 500, 1200, 1500, 2200 },
				SlamRings = { 4, 5, 6, 7, 9 },
				SpinAttackDamage = { 130, 300, 800, 990, 1300 },
				SummonCount = { 7, 8, 9, 10, 11 },
				SummonHeal = { 0.50, 1, 1, 1, 1 },
				SummonMaxHeal = { 4, 7, 8, 8, 10 },
			},
		},

		AIAggroRange = 60,
	},

	{
		Name = "The Wild Wild West",
		Image = "rbxassetid://4556892743",
		ZombieTypes = {
			Common = 3,
			Gunslinger = 1,
			Shotgun = 1,
		},
		SpecialZombies = { "Lasso", "Sniper" },
		LoadingColor = Color3.fromRGB(255, 194, 96),
		LockedArena = true,

		Difficulties = {
			{
				MinLevel = 28,
				Style = Easy,

				Rooms = 4,
				XP = 8000,
				ZombieSpawnRate = 0.6,
			},

			{
				MinLevel = 52,
				Style = Medium,

				Rooms = 6,
				XP = 350000,
				ZombieSpawnRate = 0.7,
			},

			{
				MinLevel = 74,
				Style = Hard,

				Rooms = 7,
				XP = 11000000,
				ZombieSpawnRate = 0.8,
			},

			{
				MinLevel = 98,
				Style = VeryHard,

				Rooms = 7,
				XP = 500000000,
				ZombieSpawnRate = 0.8,
			},

			{
				MinLevel = 118,
				Style = Extreme,

				Rooms = 7,
				XP = 9000000000,
				ZombieSpawnRate = 0.8,
			},
		},

		Loot = classicGunsPatched({
			Armor = {
				Common = { 32 },
				Uncommon = { 33 },
				Rare = { 34 },
				Epic = { 35 },
				Legendary = { 36 },
			},

			Helmet = {
				Common = { 21 },
				Uncommon = { 22 },
				Rare = { 23 },
				Epic = { 24 },
				Legendary = { 25 },
			},
		}, {
			Pistol = {
				Common = { 11 },
				Uncommon = { 12 },
				Rare = { 13 },
				Epic = { 14 },
				Legendary = { 15 },
			},
		}),

		Stats = {
			Common = {
				Health = { 400, 1000, 1700, 3200, 3600 },
				Damage = { 80, 180, 300, 550, 800 },
				Speed = { 14, 14, 14, 15, 15 },
			},

			Gunslinger = {
				Health = { 400, 1000, 1700, 3200, 3600 },
				Damage = { 160, 360, 600, 1100, 1600 },
				Speed = { 14, 14, 14, 15, 15 },
				ActivationTime = constant(1.1),
				Range = { 40, 40, 50, 50, 70 },
				Cooldown = { 4, 4, 3, 3, 2 },
			},

			Shotgun = {
				Health = { 600, 1200, 2300, 3500, 4200 },
				Damage = { 80, 180, 300, 550, 800 },
				Speed = { 15, 15, 15, 15, 16 },
				ActivationTime = constant(1.1),
				Range = { 30, 30, 30, 40, 50 },
				Cooldown = { 4, 4, 3, 3, 2 },
			},

			Lasso = {
				Health = { 5000, 6000, 7000, 8000, 10000 },
				Damage = { 200, 500, 800, 1400, 2200 },
				Cooldown = { 4, 3, 3, 3, 2 },
				Speed = { 10, 11, 11, 11, 12 },
			},

			Sniper = {
				Health = { 300, 900, 1500, 2500, 3000 },
				Damage = { 75, 150, 250, 450, 600 },
				Speed = constant(0),
			},

			Boss = {
				Health = { 15000, 25000, 50000, 195000, 265000 },
				ShootFrenzyDamage = { 65, 150, 250, 300, 450 },
				SummonCount = { 3, 4, 4, 4, 4 },
			},
		},

		AIAggroRange = 90,
	},

	{
		Name = "The Magic Tower",
		Image = "rbxassetid://4708947976",
		ZombieTypes = {
			Common = 3,
			Fast = 1,
			Projectile = 1,
			Strong = 1,
		},
		SpecialZombies = { "DarkMagic", "Enchanter" },
		LoadingColor = Color3.fromRGB(155, 89, 182),
		LockedArena = true,
		TreasureDelayTime = 2.5,

		DropTable = {
			Crystal = 2,
		},

		Difficulties = {
			{
				MinLevel = 10,
				Style = Easy,

				XP = 1500,
				Rooms = 4,
				ZombieSpawnRate = 0.3,
			},

			{
				MinLevel = 36,
				Style = Medium,

				XP = 25000,
				Rooms = 6,
				ZombieSpawnRate = 0.35,
			},

			{
				MinLevel = 60,
				Style = Hard,

				XP = 1300000,
				Rooms = 7,
				ZombieSpawnRate = 0.40,
			},

			{
				MinLevel = 82,
				Style = VeryHard,

				XP = 55000000,
				Rooms = 7,
				ZombieSpawnRate = 0.4,
			},

			{
				MinLevel = 102,
				Style = Extreme,

				XP = 1400000000,
				Rooms = 7,
				ZombieSpawnRate = 0.45,
			},
		},

		Loot = classicGunsPatched({
			Armor = {
				Common = { 47, 48, 49, 50, 51 },
				Uncommon = { 46 },
				Rare = { 45 },
				Epic = { 44 },
				Legendary = { 42, 43 },
			},

			Helmet = {
				Common = { 36 },
				Uncommon = { 35 },
				Rare = { 34 },
				Epic = { 33 },
				Legendary = { 31, 32 },
			},
		}, {
			Crystal = {
				Common = { 1 },
				Uncommon = { 2 },
				Rare = { 3 },
				Epic = { 4 },
				Legendary = { 5 },
			},
		}),

		Stats = {
			Common = {
				Damage = { 80, 190, 560, 635, 800 },
				Health = { 210, 660, 1100, 2382, 2600 },
				ReactionTime = TOWER_REACTION_TIME,
				Speed = { 14, 14.2, 14.4, 14.5, 14.75 },
			},

			Strong = {
				Damage = { 100, 240, 700, 800, 950 },
				Health = { 440, 900, 1300, 2500, 3200 },
				ReactionTime = TOWER_REACTION_TIME,
				Speed = { 13, 13.2, 13.4, 13.5, 13.75 },
			},

			Fast = {
				Damage = { 40, 95, 280, 315, 400 },
				Health = { 110, 440, 660, 1542, 1700 },
				ReactionTime = TOWER_REACTION_TIME,
				Speed = { 16, 16.2, 16.4, 16.5, 16.75 },
			},

			Projectile = {
				Damage = { 40, 95, 280, 315, 400 },
				Health = { 100, 440, 660, 1542, 1700 },
				ReactionTime = TOWER_REACTION_TIME,
				Speed = { 8, 9, 9, 9, 9 },
			},

			Ultra = {
				Damage = { 100, 240, 700, 800, 950 },
				Health = { 880, 1800, 2600, 4500, 6000 },
				ReactionTime = TOWER_REACTION_TIME,
				Speed = { 13, 13.2, 13.4, 13.5, 13.75 },
			},

			Enchanter = {
				Damage = { 100, 240, 700, 800, 950 },
				Health = { 440, 900, 1300, 2500, 3200 },
				ReactionTime = TOWER_REACTION_TIME,
				Speed = { 11, 12, 12, 12, 12 },
				Buff = { 0.20, 0.22, 0.24, 0.26, 0.30 },
			},

			DarkMagic = {
				Damage = { 80, 190, 560, 635, 800 },
				Health = { 600, 1200, 1700, 3000, 3700 },
				ReactionTime = TOWER_REACTION_TIME,
				Speed = { 10, 11, 11, 11, 11 },
			},

			Boss = {
				Health = { 11111, 20000, 42000, 169000, 245000 },
				FlameBreathDamage = { 120, 220, 500, 600, 850 },
				MagicMissilesDamage = { 120, 220, 500, 600, 850 },
				MissileRingDamage = { 120, 220, 500, 600, 850 },
			}
		},

		AIAggroRange = 60,
	},
}

for _, campaign in ipairs(Campaigns) do
	for _, difficulty in ipairs(campaign.Difficulties) do
		difficulty.Gold = difficulty.Style.Gold
	end
end

assert(campaignsType(Campaigns))

return Campaigns
