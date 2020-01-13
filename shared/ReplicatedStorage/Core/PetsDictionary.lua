local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LootStyles = require(ReplicatedStorage.Core.LootStyles)

local Pets = ReplicatedStorage.Pets

local function pet(name, model)
	return {
		Name = name,
		Model = model,
	}
end

return {
	EggCost = 1000,

	Pets = {
		pet("Mario", Pets.Mario),
	},

	Rarities = {
		{
			Style = LootStyles[1],
			Damage = 0.05,
			FireRate = 1,
			DropRate = 50,
		},

		{
			Style = LootStyles[2],
			Damage = 0.08,
			FireRate = 1.2,
			DropRate = 25,
		},

		{
			Style = LootStyles[3],
			Damage = 0.11,
			FireRate = 1.3,
			DropRate = 15,
		},

		{
			Style = LootStyles[4],
			Damage = 0.14,
			FireRate = 1.4,
			DropRate = 8,
		},

		{
			Style = LootStyles[5],
			Damage = 0.25,
			FireRate = 2,
			DropRate = 2,
		},
	},
}
