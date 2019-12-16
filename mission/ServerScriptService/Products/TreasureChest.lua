local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

if Dungeon.GetDungeonData("Gamemode") ~= "Mission" then
	return {
		Activate = function() end
	}
end

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local GenerateTreasureLoot = require(ServerScriptService.Libraries.GenerateTreasureLoot)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)

local TreasureChestProduct = {}

local rewarded = false

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

function TreasureChestProduct.Activate(player, receiptInfo)
	if receiptInfo.ProductId == 934232605 or receiptInfo.ProductId == 934232697 then
		if rewarded then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		rewarded = true

		for _, player in pairs(Players:GetPlayers()) do
			local loot = copy(GenerateTreasureLoot:expect())
			local inventorySpace = InventorySpace(player):expect()

			loot.Level = player.PlayerData.Level.Value
			loot.UUID = HttpService:GenerateGUID(false):gsub("-", "")

			DataStore2("Inventory", player):Update(function(inventory)
				if #inventory >= inventorySpace then
					return inventory
				end

				table.insert(inventory, loot)
				return inventory
			end)

			DataStore2.SaveAllAsync(player)
		end

		ReplicatedStorage.Remotes.TreasureBought:FireAllClients(player)

		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

return TreasureChestProduct
