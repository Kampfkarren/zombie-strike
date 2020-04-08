local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)

local BADGE_GIGA_ZOMBIE = 2124495353
local BADGE_YOU_PLAYED = 2124495352

local LEVEL_BADGES = {
	[30] = 2124495354,
	[60] = 2124495355,
	[72] = 2124495356,
	[101] = 2124497453,
	[130] = 2124500479,
}

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

	for badgeLevel, badge in pairs(LEVEL_BADGES) do
		if level >= badgeLevel then
			awardBadge(player, badge)
		end
	end

	if level > 1 then
		awardBadge(player, BADGE_GIGA_ZOMBIE)
	end
end)
