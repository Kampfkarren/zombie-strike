local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GoldShopItemsUtil = require(ReplicatedStorage.Libraries.GoldShopItemsUtil)
local NPCOpener = require(ReplicatedStorage.Libraries.NPCOpener)

local requestedLog = false
local requestedGoldShop = false

NPCOpener("CollectionLog", function()
	if not requestedLog then
		requestedLog = true
		ReplicatedStorage.Remotes.UpdateCollectionLog:FireServer()
	end
end)

NPCOpener("GoldShop", function()
	if not requestedGoldShop then
		requestedGoldShop = true
		ReplicatedStorage.Remotes.GoldShop:FireServer(
			GoldShopItemsUtil.GoldShopPacket.Requesting
		)
	end
end, true, "rbxassetid://5091305452")

NPCOpener("Shopkeeper", function() end, true, "rbxassetid://5091306153")
NPCOpener("Vouchers", function() end, true, "rbxassetid://5091357325")

NPCOpener("Equipment")
NPCOpener("PetShop")
