local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local InventoryUtil = require(ServerScriptService.Libraries.InventoryUtil)
local SellCost = require(ReplicatedStorage.Libraries.SellCost)

DataStore2.Combine("DATA", "Gold")

ReplicatedStorage.Remotes.Sell.OnServerEvent:connect(function(player, uuid)
	local inventory = Data.GetPlayerData(player, "Inventory")
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

	if player:FindFirstChild("Trading") then
		warn("player is trading!")
		return
	end

	local reward = SellCost(item)
	InventoryUtil.RemoveItems(player, { index })
	DataStore2("Gold", player):Increment(reward)
end)
