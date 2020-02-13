local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local assign = require(ReplicatedStorage.Core.assign)
local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local DungeonState = require(ServerScriptService.DungeonState)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local Loot = require(ReplicatedStorage.Core.Loot)
local PetsDictionary = require(ReplicatedStorage.Core.PetsDictionary)
local Promise = require(ReplicatedStorage.Core.Promise)

local Equipment = ReplicatedStorage.Equipment

local ATTACHMENT_DROP_RATE = 0.2
local FREE_EPIC_AFTER = 0
local WEAPON_DROP_RATE = 0.6

local PITY_TIMER_BASE = 0.5
local PITY_TIMER_MISSIONS_UNTIL_GUARANTEED = 25
local PITY_TIMER_SLOW_RATE = 0.04

local RARITY_PERCENTAGES = {
	{ PITY_TIMER_BASE, 5 },
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

DataStore2.Combine("DATA", "Brains", "LegendariesObtained")

local function getLegendaryChance(dungeonsSinceLast)
	local s = PITY_TIMER_BASE
	local p = PITY_TIMER_MISSIONS_UNTIL_GUARANTEED
	local r = PITY_TIMER_SLOW_RATE

	return s * ((100 / s) ^ (1 / p)) ^ (((dungeonsSinceLast ^ 2) * (r * (dungeonsSinceLast - p) + 1)) / p)
end

local function getModel(type, rarity)
	if table.find(Loot.Attachments, type) then
		return rarity
	else
		local loot

		if Dungeon.GetDungeonData("Gamemode") == "Boss" then
			loot = assign(Dungeon.GetDungeonData("BossInfo").Loot, Campaigns[1].Loot)
		else
			loot = Dungeon.GetDungeonData("CampaignInfo").Loot
		end

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
	local playerLevel = Data.GetPlayerData(player, "Level")

	if Dungeon.GetDungeonData("Gamemode") == "Arena" then
		return 1
	elseif Dungeon.GetDungeonData("Gamemode") ~= "Mission" then
		return math.max(playerLevel - math.random(0, 3), 1)
	end

	local dungeonLevelMin = Dungeon.GetDungeonData("DifficultyInfo").MinLevel

	local nextDungeon = nextDungeonLevel() or dungeonLevelMin + 4

	return math.random(dungeonLevelMin, math.min(playerLevel, nextDungeon))
end

local takenAdvantageOfFreeLoot = {}

local function getChancesFor(player, moreLegendaries, dungeonsSinceLast)
	local base = moreLegendaries and RARITY_PERCENTAGES_LEGENDARY or RARITY_PERCENTAGES
	local pet = Data.GetPlayerData(player, "Pet")
	local luckBoost = (pet and PetsDictionary.Rarities[pet.Rarity].Luck or 0) / 100

	local chances = {}
	local sum = 0

	for index, data in ipairs(base) do
		local chance, rarity = unpack(data)

		if rarity == 1 then
			-- Take away chance from commons
			chance = chance - luckBoost
		elseif rarity == 4 or rarity == 5 then
			chance = chance + (luckBoost / 2)
		end

		chances[index] = { chance, rarity }
		sum = sum + chance
	end

	if not moreLegendaries then
		local newLegendaryChance = getLegendaryChance(dungeonsSinceLast)
		local half = (newLegendaryChance - PITY_TIMER_BASE) / 2
		chances[1] = { newLegendaryChance, 5 }
		chances[#chances] = { math.max(0, chances[#chances][1] - half), 1 }
		chances[#chances - 1] = { math.max(0, chances[#chances - 1][1] - half), 2 }
	end

	if sum - 100 > 0.00001 then
		warn("getChancesFor result didn't add up! added to " .. sum)
		return base
	end

	return chances
end

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

	local dungeonsSinceLast

	-- We don't pity timer in arena for two reasons
	-- 1. Players would get low level legendaries reguarly
	-- 2. We'd have to set the data store in the arena, otherwise people would
	-- frequently get legendaries.
	if Dungeon.GetDungeonData("Gamemode") ~= "Arena" then
		dungeonsSinceLast = Data.GetPlayerData(player, "DungeonsSinceLastLegendary")
	else
		dungeonsSinceLast = 1
	end

	local cumulative = 0
	for _, percent in ipairs(getChancesFor(
		player,
		moreLegendaries,
		dungeonsSinceLast
	)) do
		if rarityRng <= cumulative + percent[1] then
			return percent[2]
		else
			cumulative = cumulative + percent[1]
		end
	end

	warn("unreachable code! GenerateLoot did not give a rarity percent")
	return 1
end

local function generateLootItem(player)
	-- First, see if the gamemode has anything it wants to give
	local generateGamemodeLoot = DungeonState.CurrentGamemode.GenerateLootItem
	if generateGamemodeLoot then
		local gamemodeLoot = generateGamemodeLoot(player)
		if gamemodeLoot then
			return gamemodeLoot
		end
	end

	local rng = Random.new()
	local level = getLootLevel(player)
	local rarity = getLootRarity(player)

	local uuid = HttpService:GenerateGUID(false):gsub("-", "")

	local bossLoot = Dungeon.GetDungeonData("Gamemode") == "Boss"
		and Dungeon.GetDungeonData("BossInfo").Loot
		or {}

	if (takenAdvantageOfFreeLoot[player] or rng:NextNumber() <= WEAPON_DROP_RATE)
		or (
			-- If the boss has no custom loot, just always give weapons
			-- This could be changed so that it gives attachments too, though
			Dungeon.GetDungeonData("Gamemode") == "Boss"
			and bossLoot.Armor == nil
			and bossLoot.Helmet == nil
		)
	then
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
		return Promise.async(function(resolve)
			local _, dungeonsSinceLastStore = Data.GetPlayerData(player, "DungeonsSinceLastLegendary")

			local lootTable = {}
			local gamemodeLoot = {}

			for _ = 1, amount do
				local lootItem = generateLootItem(player)

				if lootItem.GamemodeLoot then
					if lootItem.Type == "Brains" then
						DataStore2("Brains", player):Increment(lootItem.Brains, 0)
					end

					table.insert(gamemodeLoot, lootItem)
				else
					if lootItem.Rarity == 5 then
						-- Multiple items game pass shouldn't mean multiple legendaries
						dungeonsSinceLastStore:Set(0)
						DataStore2("LegendariesObtained", player):IncrementAsync(1, 0)
					end

					table.insert(lootTable, lootItem)
				end
			end

			resolve(lootTable, gamemodeLoot)
		end)
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
