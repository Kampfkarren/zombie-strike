local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local ZombiePassRewards = require(ServerScriptService.Shared.ZombiePassRewards)

local ZombiePass = {}

local PRODUCT_ID = 945698356

function ZombiePass.Activate(player, receiptInfo)
	if receiptInfo.ProductId == PRODUCT_ID then
		local zombiePass, zombiePassStore = Data.GetPlayerData(player, "ZombiePass")

		local alreadyPremium = zombiePass.Premium
		zombiePass.Premium = true
		zombiePassStore:Set(zombiePass)

		if alreadyPremium then
			-- This can happen if a player buys the zombie pass, it doesn't save here...
			-- ...then they leave, it saves *then*, and they join back
			-- This *shouldn't* cause the player to be able to buy the zombie pass *twice*,
			-- as all other processes will treat the player as premium whether it saved or not.
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			-- Otherwise, reward them all their new stuff
			local levels = {}

			for level = 1, zombiePass.Level - 1 do
				table.insert(levels, level)
			end

			ZombiePassRewards.GrantRewards(player, levels):awaitValue()
			ReplicatedStorage.Remotes.ZombiePass:FireClient(player, zombiePass.Level, zombiePass.XP, true, levels)
		end

		local success = pcall(function()
			DataStore2.SaveAll(player)
		end)

		if success then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end
end

return ZombiePass
