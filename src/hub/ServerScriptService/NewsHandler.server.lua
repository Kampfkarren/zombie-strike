local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)
local MockPlayer = require(ReplicatedStorage.Core.MockData.MockPlayer)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local Promise = require(ReplicatedStorage.Core.Promise)

local SendNews = ReplicatedStorage.Remotes.SendNews

local DEBUG_NO_NEWS_FOR_ANYONE = false
local DUNGEONS_UNTIL_UPGRADE = 3
local INVENTORY_SPACE_TO_ALERT = 25 / 30
local LAST_GAME_UPDATE = 9

local MOCK_PLAYER = MockPlayer()
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

local function checkNewUpdate(player)
	return Data.GetPlayerDataAsync(player, "GameVersion")
		:andThen(function(version, versionStore)
			if version < LAST_GAME_UPDATE then
				versionStore:Set(LAST_GAME_UPDATE)
				return { { "NewUpdate" } }
			else
				return NO_NEWS
			end
		end)
end

local function checkUnlockedContent(player)
	return Data.GetPlayerDataAsync(player, "LastKnownDifficulties")
		:andThen(function(lastKnownDifficulties, difficultyStore)
			local news = {}

			return Data.GetPlayerDataAsync(player, "Level")
				:andThen(function(level)
					local newLastKnownDifficulties = {}

					for campaignIndex, campaign in ipairs(Campaigns) do
						for difficultyIndex, difficulty in ipairs(campaign.Difficulties) do
							if level >= difficulty.MinLevel then
								newLastKnownDifficulties[tostring(campaignIndex)] = difficultyIndex
							else
								break
							end
						end
					end

					for campaignIndex, knownDifficulty in pairs(newLastKnownDifficulties) do
						if lastKnownDifficulties[campaignIndex] == nil then
							table.insert(news, { "CampaignUnlocked", { tonumber(campaignIndex) }})
						elseif lastKnownDifficulties[campaignIndex] ~= knownDifficulty then
							table.insert(news, { "DifficultyUnlocked", { tonumber(campaignIndex), knownDifficulty }})
						end
					end

					if #news > 0 then
						difficultyStore:Set(newLastKnownDifficulties)
					end

					return news
				end)
		end)
end

local function checkUseInventory(player)
	return Data.GetPlayerDataAsync(player, "Inventory")
		:andThen(function(inventory)
			for equippable in pairs(Data.Equippable) do
				local default = MOCK_PLAYER[equippable]
				local equipped = Data.GetPlayerData(player, equippable)

				for key, value in pairs(equipped or {}) do
					if key ~= "UUID" and default ~= nil and default[key] ~= value then
						-- They equipped something different
						return NO_NEWS
					end
				end
			end

			-- All equipment is normal, but do they even have any other items?
			if #inventory == 3 then
				return NO_NEWS
			end

			-- They have items, but haven't equipped anything
			return { { "UseInventory" } }
		end)
end

local function checkUpgradeSomething(player)
	return Data.GetPlayerDataAsync(player, "UpgradedSomething")
		:andThen(function(upgradedSomething)
			if not upgradedSomething then
				return Data.GetPlayerDataAsync(player, "DungeonsPlayed")
					:andThen(function(dungeonsPlayed)
						if dungeonsPlayed > DUNGEONS_UNTIL_UPGRADE then
							return { { "UpgradeSomething" }}
						else
							return NO_NEWS
						end
					end)
			end
		end)
end

Players.PlayerAdded:connect(function(player)
	if RunService:IsStudio() and DEBUG_NO_NEWS_FOR_ANYONE then
		return
	end

	Promise.all({
		checkInventorySpace(player),
		checkNewUpdate(player),
		checkUnlockedContent(player),
		checkUseInventory(player),
		checkUpgradeSomething(player),
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
