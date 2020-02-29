local AnalyticsService = game:GetService("AnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local inspect = require(ReplicatedStorage.Core.inspect)

local DEBUG_ANALYTICS = true

local Analytics = {}

function Analytics.Debug(...)
	if DEBUG_ANALYTICS then
		print("[Analytics]", ...)
	end
end

if RunService:IsStudio() then
	print("[Analytics] Debug place -- no analytics will be sent")
	Analytics.FireEvent = function(eventCategory, eventValue)
		Analytics.Debug("Firing:", eventCategory, "-", inspect(eventValue))
	end
else
	function Analytics.FireEvent(eventCategory, eventValue)
		Analytics.Debug("Firing:", eventCategory, "-", inspect(eventValue))
		AnalyticsService:FireEvent(eventCategory, eventValue)
	end
end

function Analytics.DungeonStarted()
	local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

	Dungeon.GetDungeonTable():andThen(function(dungeonTable)
		Analytics.FireEvent("DungeonStarted", dungeonTable)
	end)
end

function Analytics.CollectionLogRequested(player)
	Analytics.FireEvent("CollectionLogRequested", {
		UserId = player.UserId,
	})
end

function Analytics.CosmeticBought(player, itemName)
	Analytics.FireEvent("CosmeticBought", {
		UserId = player.UserId,
		ItemName = itemName,
	})
end

return Analytics
