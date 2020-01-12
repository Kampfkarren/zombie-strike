local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loot = require(ReplicatedStorage.Core.Loot)

local Pets = ReplicatedStorage.Pets

local function pet(name, model)
	return {
		Name = name,
		Model = model,
	}
end

return {
	Pets = {
		pet("Mario", Pets.Mario),
	},

	Rarities = {
		{
			Style = Loot.Rarities[1],
			Damage = 0.05,
			FireRate = 1,
		},
	},
}
