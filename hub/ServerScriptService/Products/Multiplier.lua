local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local XPMultiplierDictionary = require(ReplicatedStorage.XPMultiplierDictionary)

local MultiplierProduct = {}

DataStore2.Combine("DATA", "XPExpires")

function MultiplierProduct.Activate(player, receiptInfo)
	for _, product in pairs(XPMultiplierDictionary) do
		if product.Product == receiptInfo.ProductId then
			DataStore2("XPExpires", player):Update(function(current)
				if os.time() > current then
					return os.time() + product.Time
				else
					return current + product.Time
				end
			end)

			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
end

return MultiplierProduct
