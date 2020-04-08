local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)

return function(context, item, level, rarityName)
	local player = context.Executor

	local rarity

	for index, currentRarity in ipairs(LootStyles) do
		if currentRarity.Name == rarityName then
			rarity = index
			break
		end
	end

	local inventory, inventoryStore = Data.GetPlayerData(player, "Inventory")

	local inventoryItem = {
		Level = level,
		Rarity = rarity,
		Type = item.Name:match("([A-Za-z]+)"),

		Upgrades = 0,
		Favorited = false,

		Model = tonumber(item.Name:match("([0-9]+)")),
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}

	if item.ItemType.Value == "Gun" then
		inventoryItem.Bonus = 0
	end

	table.insert(inventory, inventoryItem)

	inventoryStore:Set(inventory)
end
