local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local GunScaling = require(ReplicatedStorage.Libraries.GunScaling)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local Promise = require(ReplicatedStorage.Core.Promise)

local WEAPON_DROP_RATE = 0.67

local function generateLootItem(player)
	local rng = Random.new()

	local currentLevel = player.PlayerData.Level.Value
	local level = currentLevel
	if level > 5 then
		level = level - rng:NextInteger(0, 2)
	end

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
			CritChance = stats.CritChance,
			Damage = stats.Damage,
			FireRate = stats.FireRate,
			Level = level,
			Magazine = stats.Magazine,
			Model = GunScaling.Model(type, rarity),
			Name = quality .. " Poopoo",
			Rarity = rarity,
			UUID = uuid,
		}

		return loot
	else
		local type, model

		if rng:NextNumber() >= 0.5 then
			-- type = "Armor"
			type = "Helmet"
		else
			type = "Helmet"
		end

		-- model = ArmorScaling.Model(type, rarity)
		model = ((Dungeon.GetDungeonData("Campaign") - 1) * 5) + rarity

		local loot = {
			Level = level,
			Name = "Poopy",
			Rarity = rarity,
			Type = type,

			Model = model,
			UUID = uuid,
		}

		return loot
	end
end

local function getLootAmount(player)
	local amount = 1

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
			table.insert(lootTable, generateLootItem(player))
		end

		return lootTable
	end)
end

return generateLoot
