local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BrainsDictionary = require(ReplicatedStorage.BrainsDictionary)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)

local MultiplierProduct = {}

DataStore2.Combine("DATA", "Brains")

function MultiplierProduct.Activate(player, receiptInfo)
	for _, product in pairs(BrainsDictionary) do
		if product.Product == receiptInfo.ProductId then
			DataStore2("Brains", player):Increment(product.Brains)
			FastSpawn(function()
				DataStore2.SaveAll(player)
			end)

			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
end

return MultiplierProduct
