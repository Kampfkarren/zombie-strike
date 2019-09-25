local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local GunScaling = require(ReplicatedStorage.Libraries.GunScaling)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local Loot = require(ReplicatedStorage.Core.Loot)
local Promise = require(ReplicatedStorage.Core.Promise)

local FREE_EPIC_AFTER = 0
local WEAPON_DROP_RATE = 0.67

local function getModel(type, rarity)
	local loot = Dungeon.GetDungeonData("CampaignInfo").Loot
	local models = assert(loot[type], "No loot for " .. type)[Loot.Rarities[rarity].Name]
	return models[math.random(#models)]
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

	local dungeonLevelMin = Dungeon.GetDungeonData("DifficultyInfo").MinLevel

	local nextDungeon = nextDungeonLevel() or dungeonLevelMin + 4

	return math.random(dungeonLevelMin, math.min(playerLevel, nextDungeon))
end

local takenAdvantageOfFreeLoot = {}

local function getLootRarity(player)
	if Data.GetPlayerData(player, "DungeonsPlayed") == FREE_EPIC_AFTER
		and not takenAdvantageOfFreeLoot[player]
	then
		takenAdvantageOfFreeLoot[player] = true
		return 4
	end

	local rng = Random.new()

	local rarityRng = rng:NextNumber() * 100
	local rarity

	-- Numbers are cumulative sums
	if rarityRng <= 0.1 then
		rarity = 5
	elseif rarityRng <= 5 then
		rarity = 4
	elseif rarityRng <= 20 then
		rarity = 3
	elseif rarityRng <= 40 then
		rarity = 2
	else
		rarity = 1
	end

	return rarity
end

local function generateLootItem(player)
	local rng = Random.new()
	local level = getLootLevel(player)
	local rarity = getLootRarity(player)

	local uuid = HttpService:GenerateGUID(false):gsub("-", "")

	if rng:NextNumber() <= WEAPON_DROP_RATE then
		local type = GunScaling.RandomType()

		local stats = GunScaling.BaseStats(type, level, rarity)

		local funny = rng:NextInteger(0, 35)
		stats.Damage = math.floor(stats.Damage * (1 + funny / 35))

		local quality
		if funny <= 4 then
			quality = "Average"
		elseif funny <= 9 then
			quality = "Superior"
		elseif funny <= 14 then
			quality = "Choice"
		elseif funny <= 19 then
			quality = "Valuable"
		elseif funny <= 24 then
			quality = "Great"
		elseif funny <= 29 then
			quality = "Ace"
		elseif funny <= 34 then
			quality = "Extraordinary"
		else
			quality = "Perfect"
		end

		local loot = {
			Type = type,
			CritChance = stats.CritChance * 100,
			Damage = stats.Damage,
			FireRate = stats.FireRate * 100,
			Level = level,
			Magazine = stats.Magazine,
			Model = getModel(type, rarity),
			Name = quality .. " Poopoo",
			Rarity = rarity,
			UUID = uuid,
		}

		return loot
	else
		local type

		if rng:NextNumber() >= 0.5 then
			type = "Armor"
		else
			type = "Helmet"
		end

		local loot = {
			Level = level,
			Name = "Poopy",
			Rarity = rarity,
			Type = type,

			Model = getModel(type, rarity),
			UUID = uuid,
		}

		return loot
	end
end

local function getLootAmount(player)
	local amount = 1

	if Dungeon.GetDungeonData("Hardcore") then
		amount = amount + 1
	end

	return Promise.all({
		Data.GetPlayerDataAsync(player, "Inventory"),
		InventorySpace(player),
	}):andThen(function(data)
		local inventory, space = unpack(data)
		local difference = space - #inventory

		if amount > difference then
			warn("player's inventory is too full!")
			ReplicatedStorage.Remotes.InventoryFull:FireClient(player, amount - difference)
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

return generateLoot
