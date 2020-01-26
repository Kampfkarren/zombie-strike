-- Removes the Name property from loot
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

return function(player)
	local inventoryStore = DataStore2("Inventory", player)

	local inventory = inventoryStore:Get()

	for index, item in ipairs(inventory) do
		local newItem = {
			Type = item.Type,
			Level = item.Level,
			Rarity = item.Rarity,
			Bonus = item.Bonus,
			Upgrades = item.Upgrades,

			Model = item.Model,
			UUID = item.UUID,
		}

		inventory[index] = newItem
	end

	inventoryStore:Set(inventory)
end
