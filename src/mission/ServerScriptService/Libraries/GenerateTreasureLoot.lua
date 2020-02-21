local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local GenerateLoot = require(ServerScriptService.Libraries.GenerateLoot)
local Promise = require(ReplicatedStorage.Core.Promise)

local LEGENDARY_CHANCE = 0.1
local SPAWN_RATE = 0.33

if math.random() > SPAWN_RATE then
	return Promise.resolve(nil)
end

local rng = Random.new()

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

	local gunType = GenerateLoot.RandomGunType()
	local models, rarity, bonus

	if rng:NextNumber() <= LEGENDARY_CHANCE then
		rarity = 5
		models = campaignInfo.Loot[gunType].Legendary
		bonus = rng:NextInteger(0, 34)
	else
		rarity = 4
		models = campaignInfo.Loot[gunType].Epic
		bonus = 35
	end

	return {
		Type = gunType,
		Level = 0,
		Rarity = rarity,
		Bonus = bonus,
		Model = models[rng:NextInteger(1, #models)],
		Upgrades = 0,
		Favorited = false,
		UUID = "TREASURE_LOOT", -- Changed at runtime
	}
end)
