-- Adds "Upgrades" to items
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

return function(player)
	local inventoryStore = DataStore2("Inventory", player)

	local inventory = inventoryStore:Get()

	for _, item in ipairs(inventory) do
		item.Upgrades = 0
	end

	inventoryStore:Set(inventory):await()
end
