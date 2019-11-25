local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local Promise = require(ReplicatedStorage.Core.Promise)

local SendNews = ReplicatedStorage.Remotes.SendNews

local INVENTORY_SPACE_TO_ALERT = 25 / 30

local NO_NEWS = newproxy(true)

local function checkInventorySpace(player)
	return InventorySpace(player)
		:andThen(function(inventorySpace)
			return Data.GetPlayerDataAsync(player, "Inventory"):andThen(function(inventory)
				if #inventory / inventorySpace >= INVENTORY_SPACE_TO_ALERT then
					return { { "InventoryFull" } }
				end

				return NO_NEWS
			end)
		end)
end

local function checkUnlockedContent(player)
	return Data.GetPlayerDataAsync(player, "LastKnownDifficulty")
		:andThen(function(lastKnownDifficulty, difficultyStore)
			local campaignIndex = math.floor(lastKnownDifficulty / 10)
			local difficultyIndex = lastKnownDifficulty % 10

			local campaign = Campaigns[campaignIndex]
			local newCampaign = false
			local check, dataForm

			if #campaign.Difficulties == difficultyIndex then
				-- They're on the last difficulty, check if they can do the next one
				local nextCampaign = Campaigns[campaignIndex + 1]
				if nextCampaign == nil then
					-- They finished every difficulty!
					return NO_NEWS
				end

				newCampaign = true
				check = nextCampaign.Difficulties[1]
				dataForm = ((campaignIndex + 1) * 10) + 1
			else
				check = campaign.Difficulties[difficultyIndex + 1]
				dataForm = (campaignIndex * 10) + difficultyIndex + 1
			end

			assert(check ~= nil)

			return Data.GetPlayerDataAsync(player, "Level")
				:andThen(function(level)
					if level >= check.MinLevel then
						difficultyStore:Set(dataForm)

						if newCampaign then
							return {{ "CampaignUnlocked", { campaignIndex + 1 }}}
						else
							return {{ "DifficultyUnlocked", { campaignIndex, difficultyIndex + 1 }}}
						end
					end
				end)
		end)
end

Players.PlayerAdded:connect(function(player)
	Promise.all({
		checkInventorySpace(player),
		checkUnlockedContent(player),
	}):andThen(function(results)
		local news = {}

		for _, result in pairs(results) do
			if result ~= NO_NEWS then
				for _, newsItem in pairs(result) do
					table.insert(news, newsItem)
				end
			end
		end

		SendNews:FireClient(player, news)
	end)
end)
