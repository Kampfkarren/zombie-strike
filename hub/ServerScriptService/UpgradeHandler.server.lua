local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local Upgrades = require(ReplicatedStorage.Core.Upgrades)

ReplicatedStorage.Remotes.Upgrade.OnServerEvent:connect(function(player, index)
	local inventory, inventoryStore = Data.GetPlayerData(player, "Inventory")
	local item = inventory[index]
	if item == nil then
		warn("player tried to upgrade non existent item!")
		return
	end

	if item.Upgrades >= Upgrades.MaxUpgrades then
		warn("max upgrades")
		return
	end

	if player:FindFirstChild("Trading") then
		warn("player is trading!")
		return
	end

	local gold, goldStore = Data.GetPlayerData(player, "Gold")
	local cost = Upgrades.CostToUpgrade(item)
	if gold >= cost then
		goldStore:Increment(-cost)

		item.Upgrades = item.Upgrades + 1
		inventoryStore:Set(inventory)
	end
end)
