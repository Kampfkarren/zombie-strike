local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Core.Data)
local InventoryUtil = require(ServerScriptService.Libraries.InventoryUtil)

ReplicatedStorage.Remotes.FavoriteLoot.OnServerEvent:connect(function(player, uuid)
	local inventory, inventoryStore = Data.GetPlayerData(player, "Inventory")

	if player:FindFirstChild("Trading") then
		warn("player is trading!")
		return
	end

	local item = InventoryUtil.FindByUuid(inventory, uuid)
	if item == nil then
		warn("player tried to sell non existent item!")
		return
	end

	item.Favorited = not item.Favorited
	inventoryStore:Set(inventory)
end)
