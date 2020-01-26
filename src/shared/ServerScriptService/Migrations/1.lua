-- Transforms extensive inventory to minimal inventory
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

local bonuses = {
	Average = {0, 4},
	Superior = {5, 9},
	Choice = {10, 14},
	Valuable = {15, 19},
	Great = {20, 24},
	Ace = {25, 29},
	Extraordinary = {30, 34},
	Perfect = {35, 35},
}

return function(player)
	local inventoryStore = DataStore2("Inventory", player)

	local inventory = inventoryStore:Get()

	for index, item in ipairs(inventory) do
		if item.Type ~= "Armor" and item.Type ~= "Helmet" then
			local newItem = {
				Type = item.Type,
				Level = item.Level,
				Name = item.Name,
				Rarity = item.Rarity,

				Model = item.Model,
				UUID = item.UUID,
			}

			local quality = item.Name:match("(%w+)")
			assert(quality, item.Name .. " had no quality?")

			newItem.Bonus = Random.new():NextInteger(unpack(bonuses[quality]))

			inventory[index] = newItem
		end
	end

	inventoryStore:Set(inventory)
end
