local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Perks = require(ReplicatedStorage.Core.Perks)

local perkNames = {}

for _, perk in ipairs(Perks.Perks) do
	table.insert(perkNames, perk.Name)
end

return function(registry)
	local perkType = registry.Cmdr.Util.MakeEnumType(
		"Perk",
		perkNames
	)

	registry:RegisterType("perk", perkType)
	registry:RegisterType("perks", registry.Cmdr.Util.MakeListableType(perkType))
end
