local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local InventoryUtil = require(ServerScriptService.Libraries.InventoryUtil)
local SellCost = require(ReplicatedStorage.Libraries.SellCost)

DataStore2.Combine("DATA", "Gold")

ReplicatedStorage.Remotes.Sell.OnServerEvent:connect(function(player, uuid)
	local inventory = Data.GetPlayerData(player, "Inventory")

	if player:FindFirstChild("Trading") then
		warn("player is trading!")
		return
	end

	local removeIndices, reward = {}, 0

	if uuid == "*" then
		local equipped = {}

		for equippable in pairs(Data.Equippable) do
			local equippedItem = Data.GetPlayerData(player, "Equipped" .. equippable)
			if equippedItem then
				equipped[equippedItem] = true
			end
		end

		for index, item in ipairs(inventory) do
			if not equipped[index] and not item.Favorited then
				table.insert(removeIndices, index)
				reward = reward + SellCost(item)
			end
		end
	else
		local item, index = InventoryUtil.FindByUuid(inventory, uuid)
		if item == nil then
			warn("player tried to sell non existent item!")
			return
		end

		for equippable in pairs(Data.Equippable) do
			local equipped = Data.GetPlayerData(player, "Equipped" .. equippable)
			if equipped == index then
				warn("player tried to sell equipped item!")
				return
			end
		end

		reward = SellCost(item)
		table.insert(removeIndices, index)
	end

	InventoryUtil.RemoveItems(player, removeIndices)
	DataStore2("Gold", player):Increment(reward)
end)
