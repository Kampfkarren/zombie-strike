local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)

local BADGE_GIGA_ZOMBIE = 2124495353
local BADGE_YOU_PLAYED = 2124495352

local function awardBadge(player, badge)
	FastSpawn(function()
		if not BadgeService:UserHasBadgeAsync(player.UserId, badge) then
			BadgeService:AwardBadge(player.UserId, badge)
		end
	end)
end

Players.PlayerAdded:connect(function(player)
	awardBadge(player, BADGE_YOU_PLAYED)

	local level = Data.GetPlayerData(player, "Level")

	for _, campaign in pairs(Campaigns) do
		if campaign.Difficulties[#campaign.Difficulties].MinLevel <= level then
			awardBadge(player, campaign.CompletionBadge)
		end
	end

	if level > 1 then
		awardBadge(player, BADGE_GIGA_ZOMBIE)
	end
end)
