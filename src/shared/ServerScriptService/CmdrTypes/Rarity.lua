local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LootStyles = require(ReplicatedStorage.Core.LootStyles)

local rarityNames = {}

for _, loot in ipairs(LootStyles) do
	table.insert(rarityNames, loot.Name)
end

return function(registry)
	registry:RegisterType("rarity", registry.Cmdr.Util.MakeEnumType(
		"Rarity",
		rarityNames
	))
end
