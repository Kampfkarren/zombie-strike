local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local Promise = require(ReplicatedStorage.Core.Promise)

local LEGENDARY_CHANCE = 0.2
local SPAWN_RATE = 0.33

if math.random() > SPAWN_RATE then
	return Promise.resolve(nil)
end

return Promise.all({
	Dungeon.GetDungeonDataAsync("CampaignInfo"),
	Dungeon.GetDungeonDataAsync("Campaign"),
	Dungeon.GetDungeonDataAsync("Difficulty"),
}):andThen(function(results)
	local campaignInfo, campaign, difficulty = unpack(results)
	if campaign == 1 and difficulty == 1 then
		return nil
	else
		return campaignInfo
	end
end):andThen(function(campaignInfo)
	if campaignInfo == nil then
		return
	end

	local gunType = GunScaling.RandomType()
	local models, rarity

	if math.random() <= LEGENDARY_CHANCE then
		rarity = 5
		models = campaignInfo.Loot[gunType].Legendary
	else
		rarity = 4
		models = campaignInfo.Loot[gunType].Epic
	end

	return {
		Type = gunType,
		Level = 0,
		Rarity = rarity,
		Bonus = 35,
		Model = models[math.random(#models)],
		Upgrades = 0,
		Favorited = false,
		UUID = "TREASURE_LOOT", -- Changed at runtime
	}
end)
