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
	Quests = {
		KillZombies = {
			Text = "Kill %d zombies",
			Args = {
				{
					Type = "Number",
					Range = { 60, 100 },
					RoundToNearest = 5,
				},
			},
		},

		KillZombiesWeapon = {
			Text = "Kill %d zombies with a %s",
			Args = {
				{
					Type = "Number",
					Range = { 50, 80 },
					RoundToNearest = 5,
				},

				{
					Type = "Weapon",
				},
			},
		},

		KillZombiesGrenade = {
			Text = "Kill %d zombies with a grenade",
			Args = {
				{
					Type = "Number",
					Range = { 50, 80 },
					RoundToNearest = 5,
				},
			},
		},
	},
}

assert(schema(QuestsDictionary.Quests))

return QuestsDictionary
