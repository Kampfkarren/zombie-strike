local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Data = require(ReplicatedStorage.Core.Data)
local inspect = require(ReplicatedStorage.Core.inspect)
local Promise = require(ReplicatedStorage.Core.Promise)

local DEBUG_ANALYTICS = false

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

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local function getDungeonInfo()
	local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

	return Dungeon.GetDungeonTable():andThen(function(dungeonTable)
		return Promise.async(function(resolve)
			local dungeonTable = copy(dungeonTable)

			local newMembers = {}

			for _, userId in ipairs(dungeonTable.Members) do
				local newMember = { UserId = userId }

				local player = Players:GetPlayerByUserId(userId)
				if player ~= nil then
					newMember.Level = Data.GetPlayerData(player, "Level")
					newMember.Items = {}

					for equippable in pairs(Data.Equippable) do
						newMember.Items[equippable] = Data.GetPlayerData(player, equippable)
					end
				end

				table.insert(newMembers, newMember)
			end

			dungeonTable.Members = newMembers

			resolve(dungeonTable)
		end)
	end)
end

local timeStarted

function Analytics.DungeonStarted()
	getDungeonInfo():andThen(function(dungeonTable)
		timeStarted = os.time()
		Analytics.FireEvent("DungeonStarted", dungeonTable)
	end)
end

function Analytics.DungeonFinished()
	getDungeonInfo():andThen(function(dungeonTable)
		if timeStarted ~= nil then
			dungeonTable.TimeStarted = timeStarted
		end

		Analytics.FireEvent("DungeonFinished", dungeonTable)
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
