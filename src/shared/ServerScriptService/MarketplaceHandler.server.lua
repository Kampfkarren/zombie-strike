local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	for _, productScript in pairs(ServerScriptService.Products:GetChildren()) do
		local product = require(productScript)
		local decision = product.Activate(player, receiptInfo)

		if decision ~= nil then
			return decision
		end
	end

	warn("UNKNOWN PRODUCT ID! " .. receiptInfo.ProductId)
	return Enum.ProductPurchaseDecision.NotProcessedYet
end
