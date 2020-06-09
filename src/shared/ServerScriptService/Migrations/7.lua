-- Adds Perks to weapons
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Loot = require(ReplicatedStorage.Core.Loot)

DataStore2.Combine("DATA", "Inventory")

return function(player)
	local inventoryStore = DataStore2("Inventory", player)
	local inventory = inventoryStore:Get({})

	for _, item in ipairs(inventory) do
		if Loot.IsWeapon(item) then
			item.Perks = {}
			item.Upgrades = nil
		end
	end

	inventoryStore:Set(inventory):await()
end
