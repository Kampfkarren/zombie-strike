local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Core.Data)
local InventoryUtil = require(ServerScriptService.Libraries.InventoryUtil)
local Loot = require(ReplicatedStorage.Core.Loot)
local Upgrades = require(ReplicatedStorage.Core.Upgrades)

ReplicatedStorage.Remotes.Upgrade.OnServerEvent:connect(function(player, uuid)
	local inventory, inventoryStore = Data.GetPlayerData(player, "Inventory")

	local item = InventoryUtil.FindByUuid(inventory, uuid)
	if item == nil then
		warn("player tried to upgrade non existent item!")
		return
	end

	if Loot.IsAttachment(item) then
		warn("upgrading attachment")
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

		local _, upgradedSomethingStore = Data.GetPlayerData(player, "UpgradedSomething")
		upgradedSomethingStore:Set(true)
	end
end)
