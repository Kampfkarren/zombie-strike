local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)
local Perks = require(ReplicatedStorage.Core.Perks)

return function(context, item, level, rarityName, perks)
	local player = context.Executor

	local itemPerks = {}
	local rarity

	for index, currentRarity in ipairs(LootStyles) do
		if currentRarity.Name == rarityName then
			rarity = index
			break
		end
	end

	for index, perk in ipairs(Perks.Perks) do
		if table.find(perks, perk.Name) then
			table.insert(itemPerks, { index, 0 })
		end
	end

	local inventory, inventoryStore = Data.GetPlayerData(player, "Inventory")

	local inventoryItem = {
		Level = level,
		Rarity = rarity,
		Type = item.Name:match("([A-Za-z]+)"),

		Favorited = false,

		Model = tonumber(item.Name:match("([0-9]+)")),
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}

	if item.ItemType.Value == "Gun" then
		inventoryItem.Perks = itemPerks
		inventoryItem.Bonus = 0
		inventoryItem.Seed = 0
	end

	table.insert(inventory, inventoryItem)

	inventoryStore:Set(inventory)
end
