local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local Loot = require(ReplicatedStorage.Core.Loot)
local Promise = require(ReplicatedStorage.Core.Promise)

local Equipment = ReplicatedStorage.Equipment

local ATTACHMENT_DROP_RATE = 0.2
local FREE_EPIC_AFTER = 0
local WEAPON_DROP_RATE = 0.6

local RARITY_PERCENTAGES = {
	{ 0.5, 5 },
	{ 7.5, 4 },
	{ 17, 3 },
	{ 35, 2 },
	{ 40, 1 },
}

local RARITY_PERCENTAGES_LEGENDARY = {
	{ 5, 5 },
	{ 6.38, 4 },
	{ 16, 3 },
	{ 34, 2 },
	{ 39, 1 },
}

local function getModel(type, rarity)
	if table.find(Loot.Attachments, type) then
		return rarity
	else
		local loot = Dungeon.GetDungeonData("CampaignInfo").Loot
		local models = assert(loot[type], "No loot for " .. type)[Loot.Rarities[rarity].Name]
		return models[math.random(#models)]
	end
end

local function nextDungeonLevel()
	local difficulty = Dungeon.GetDungeonData("Difficulty")
	local difficulties = Dungeon.GetDungeonData("CampaignInfo").Difficulties

	if #difficulties == difficulty then
		-- Last difficulty
		local campaign = Dungeon.GetDungeonData("Campaign")

		if #Campaigns == campaign then
			-- Last campaign!
			return nil
		else
			-- There's a next campaign
			return Campaigns[campaign + 1].Difficulties[1].MinLevel
		end
	else
		-- Not last difficulty
		return difficulties[difficulty + 1].MinLevel
	end
end

local function getLootLevel(player)
	if Dungeon.GetDungeonData("Gamemode") == "Arena" then
		return 1
	end

	local playerLevel = Data.GetPlayerData(player, "Level")

	local dungeonLevelMin = Dungeon.GetDungeonData("DifficultyInfo").MinLevel

	local nextDungeon = nextDungeonLevel() or dungeonLevelMin + 4

	return math.random(dungeonLevelMin, math.min(playerLevel, nextDungeon))
end

local takenAdvantageOfFreeLoot = {}

local function getLootRarity(player)
	if ServerStorage.ForceRarity.Value > 0 then
		return ServerStorage.ForceRarity.Value
	end

	if Data.GetPlayerData(player, "DungeonsPlayed") == FREE_EPIC_AFTER
		and not takenAdvantageOfFreeLoot[player]
	then
		takenAdvantageOfFreeLoot[player] = true
		return 4
	end

	-- Hackers only get commons and uncommons ;)
	local epicFails = Data.GetPlayerData(player, "EpicFails")
	if (epicFails.CreateLobby or 0) >= 1 then
		if math.random() >= 0.7 then
			return 1
		else
			return 2
		end
	end

	local moreLegendaries = GamePasses.PlayerOwnsPass(player, GamePassDictionary.MoreLegendaries)
	if Dungeon.GetDungeonData("Gamemode") == "Mission" then
		local legendaryBonus, legendaryBonusStore = Data.GetPlayerData(player, "LegendaryBonus")

		if not legendaryBonus
			and not takenAdvantageOfFreeLoot[player]
			and moreLegendaries
		then
			takenAdvantageOfFreeLoot[player] = true
			legendaryBonusStore:Set(true)
			return 5
		end
	end

	local rng = Random.new()

	local rarityRng = rng:NextNumber() * 100

	local cumulative = 0
	for _, percent in ipairs(moreLegendaries and RARITY_PERCENTAGES_LEGENDARY or RARITY_PERCENTAGES) do
		if rarityRng <= cumulative + percent[1] then
			return percent[2]
		else
			cumulative = cumulative + percent[1]
		end
	end

	error("unreachable code! GenerateLoot did not give a rarity percent")
end

local function generateLootItem(player)
	local rng = Random.new()
	local level = getLootLevel(player)
	local rarity = getLootRarity(player)

	local uuid = HttpService:GenerateGUID(false):gsub("-", "")

	if takenAdvantageOfFreeLoot[player] or rng:NextNumber() <= WEAPON_DROP_RATE then
		local type = GunScaling.RandomType()

		local funny = rng:NextInteger(0, 35)

		local loot = {
			Type = type,
			Rarity = rarity,
			Level = level,

			Bonus = funny,
			Upgrades = 0,
			Favorited = false,

			Model = getModel(type, rarity),
			UUID = uuid,
		}

		return loot
	else
		local loot = {
			Favorited = false,
			Rarity = rarity,
			UUID = uuid,
		}

		if rng:NextNumber() <= ATTACHMENT_DROP_RATE then
			loot.Type = Loot.RandomAttachment()
		else
			loot.Level = level
			loot.Upgrades = 0

			if rng:NextNumber() >= 0.5 then
				loot.Type = "Armor"
			else
				loot.Type = "Helmet"
			end
		end

		loot.Model = getModel(loot.Type, rarity)

		return loot
	end
end

local function getLootAmount(player)
	local amount = 1

	if Dungeon.GetDungeonData("Hardcore") then
		amount = amount + 1
	end

	if GamePasses.PlayerOwnsPass(player, GamePassDictionary.MoreLoot) then
		amount = amount + 1
	end

	return Promise.all({
		Data.GetPlayerDataAsync(player, "Inventory"),
		InventorySpace(player),
	}):andThen(function(data)
		local inventory, space = unpack(data)
		local difference = space - #inventory

		if amount > difference then
			return difference
		else
			return amount
		end
	end)
end

local function generateLoot(player)
	return getLootAmount(player):andThen(function(amount)
		local lootTable = {}

		for _ = 1, amount do
			table.insert(lootTable, Promise.promisify(generateLootItem)(player))
		end

		return Promise.all(lootTable)
	end)
end

local function generateEquipment(player)
	return Data.GetPlayerDataAsync(player, "Equipment"):andThen(function(equipment)
		local chances = {}

		for _, equipmentType in pairs({ "Grenade", "HealthPack" }) do
			for index in pairs(Equipment[equipmentType]:GetChildren()) do
				if not table.find(equipment[equipmentType], index) then
					table.insert(chances, {
						Type = equipmentType,
						Index = index,
					})
				end
			end
		end

		if #chances == 0 then
			return nil
		else
			return chances[math.random(#chances)]
		end
	end)
end

return {
	GenerateEquipment = generateEquipment,
	GenerateOne = generateLootItem,
	GenerateSet = generateLoot,
}
