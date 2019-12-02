local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local Data = require(ReplicatedStorage.Core.Data)

local UpdateCosmetics = ReplicatedStorage.Remotes.UpdateCosmetics

ReplicatedStorage.Remotes.BuyCosmetic.OnServerEvent:connect(function(player, itemType, itemIndex)
	local cosmetics = Cosmetics.GetStoreItems()

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
end)
