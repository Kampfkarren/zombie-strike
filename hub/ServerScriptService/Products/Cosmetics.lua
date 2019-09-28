local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

local UpdateCosmetics = ReplicatedStorage.Remotes.UpdateCosmetics

local CosmeticsProduct = {}

function CosmeticsProduct.Activate(player, receiptInfo)
	for itemType, products in pairs(Cosmetics.Distribution) do
		for index, product in pairs(products) do
			if product == receiptInfo.ProductId then
				local item = Cosmetics.GetStoreItems()[itemType][index]

				local cosmetics, cosmeticsStore = Data.GetPlayerData(player, "Cosmetics")

				for _, owned in pairs(cosmetics.Owned) do
					if owned == item.Index then
						warn("player owned item they were buying")
						return Enum.ProductPurchaseDecision.NotProcessedYet
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
				DataStore2.SaveAllAsync(player)

				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
	end
end

return CosmeticsProduct
