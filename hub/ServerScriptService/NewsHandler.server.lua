local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local Promise = require(ReplicatedStorage.Core.Promise)

local SendNews = ReplicatedStorage.Remotes.SendNews

local INVENTORY_SPACE_TO_ALERT = 25 / 30

local NO_NEWS = newproxy(true)

local function checkInventorySpace(player)
	return InventorySpace(player)
		:andThen(function(inventorySpace)
			return Data.GetPlayerDataAsync(player, "Inventory"):andThen(function(inventory)
				if #inventory / inventorySpace >= INVENTORY_SPACE_TO_ALERT then
					return { "InventoryFull" }
				end

				return NO_NEWS
			end)
		end)
end

Players.PlayerAdded:connect(function(player)
	Promise.all({
		checkInventorySpace(player),
	}):andThen(function(results)
		local news = {}

		for _, result in pairs(results) do
			if result ~= NO_NEWS then
				for _, newsItem in pairs(result) do
					table.insert(news, newsItem)
				end
			end
		end

		SendNews:FireClient(player, news)
	end)
end)
