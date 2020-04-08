-- Replaces LastKnownDifficulty with LastKnownDifficulties
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

DataStore2.Combine("DATA", "Level", "LastKnownDifficulties")

return function(player)
	local level = DataStore2("Level", player):Get(1)

	local lastKnownDifficultiesStore = DataStore2("LastKnownDifficulties", player)
	local lastKnownDifficulties = {}

	for campaignIndex, campaign in ipairs(Campaigns) do
		for difficultyIndex, difficulty in ipairs(campaign.Difficulties) do
			if level >= difficulty.MinLevel then
				lastKnownDifficulties[tostring(campaignIndex)] = difficultyIndex
			else
				break
			end
		end
	end

	lastKnownDifficultiesStore:Set(lastKnownDifficulties):await()
end
