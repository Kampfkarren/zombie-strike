-- Adds the Favorited property to loot
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

local function copy(list)
	local copy = {}
	for index, value in pairs(list) do
		copy[index] = value
	end
	return copy
end

return function(player)
	local inventoryStore = DataStore2("Inventory", player)

	local inventory = inventoryStore:Get()

	for index, item in ipairs(inventory) do
		local newItem = copy(item)
		newItem.Favorited = false
		inventory[index] = newItem
	end

	inventoryStore:Set(inventory):await()
end
