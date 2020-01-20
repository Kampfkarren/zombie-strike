local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local Data = require(ReplicatedStorage.Core.Data)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)

local UpdateCosmetics = ReplicatedStorage.Remotes.UpdateCosmetics

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

ReplicatedStorage.Remotes.BuyCosmetic.OnServerEvent:connect(function(player, itemType, itemIndex)
	local cosmetics = Cosmetics.GetStoreItems(player)

	local items = cosmetics[itemType]
	if not items then
		warn("BuyCosmetic: itemType not found")
		return
	end

	local item = items[itemIndex]
	if not item then
		warn("BuyCosmetic: items[itemIndex] not found")
		return
	end

	local brains, brainsStore = Data.GetPlayerData(player, "Brains")
	local cost = Cosmetics.CostOf(itemType)
	if brains < cost then
		warn("BuyCosmetic: player doesn't have enough brains (you can say that again)")
		return
	end

	if itemType ~= "Mythic" and itemType ~= "Legendary" then
		local cosmetics, cosmeticsStore = Data.GetPlayerData(player, "Cosmetics")

		for _, owned in pairs(cosmetics.Owned) do
			if owned == item.Index then
				warn("BuyCosmetic: player owned item they were buying")
				return
			end
		end

		if item.Type == "LowTier" or item.Type == "HighTier" then
			table.insert(cosmetics.Owned, item.Index + 1)
			table.insert(cosmetics.Owned, item.Index + 2)
		else
			table.insert(cosmetics.Owned, item.Index)
		end

		cosmeticsStore:Set(cosmetics)
		UpdateCosmetics:FireClient(player, cosmetics.Owned, cosmetics.Equipped)
	else
		local inventory, inventoryStore = Data.GetPlayerData(player, "Inventory")
		if #inventory >= InventorySpace(player):awaitValue() then
			warn("BuyCosmetic: player bought gun when their inventory is full")
			return
		end

		local gun = copy(item)
		gun.UUID = HttpService:GenerateGUID(false):gsub("-", "")
		table.insert(inventory, gun)
		inventoryStore:Set(inventory)
	end

	brainsStore:Increment(-cost)
end)
