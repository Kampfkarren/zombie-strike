local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.Vendor.t)

local schema = t.values(t.strictInterface({
	Text = t.string,
	Args = t.array(
		t.union(
			t.strictInterface({
				Type = t.literal("Number"),
				Range = t.strictInterface({ t.number, t.number }),
				RoundToNearest = t.optional(t.number),
			}),

			t.strictInterface({
				Type = t.literal("Weapon"),
			})
		)
	),
}))

local QuestsDictionary = {
	Reward = 100,
	Quests = {
		KillZombies = {
			Text = "Kill %d zombies as a team",
			Args = {
				{
					Type = "Number",
					Range = { 100, 150 },
					RoundToNearest = 5,
				},
			},
		},

		KillZombiesWeapon = {
			Text = "Kill %d zombies with a %s as a team",
			Args = {
				{
					Type = "Number",
					Range = { 70, 100 },
					RoundToNearest = 5,
				},

				{
					Type = "Weapon",
				},
			},
		},

		KillZombiesGrenade = {
			Text = "Kill %d zombies with a grenade as a team",
			Args = {
				{
					Type = "Number",
					Range = { 70, 100 },
					RoundToNearest = 5,
				},
			},
		},

		BeatHardcoreMissions = {
			Text = "Beat %d hardcore missions",
			Args = {
				{
					Type = "Number",
					Range = { 5, 7 },
				},
			},
		},

		PlayMissionWithFriend = {
			Text = "Play %d missions with a friend",
			Args = {
				{
					Type = "Number",
					Range = { 2, 3 },
				},
			},
		},

		DefeatBossWithoutDamage = {
			Text = "Defeat %d bosses without taking any damage",
			Args = {
				{
					Type = "Number",
					Range = { 3, 3 },
				},
			},
		},

		ArenaWaves = {
			Text = "Defeat %d hordes in the arena",
			Args = {
				{
					Type = "Number",
					Range = { 10, 50 },
					RoundToNearest = 5,
				},
			},
		},
	},
}

assert(schema(QuestsDictionary.Quests))

return QuestsDictionary
