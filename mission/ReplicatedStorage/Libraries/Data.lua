local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local CoreData = require(ReplicatedStorage.Core.CoreData)
local MockData = ReplicatedStorage.Core.MockData

local MockDungeon = require(MockData.MockDungeon)
local MockPlayer = require(MockData.MockPlayer)

local Data = {}

Data.GetModel = CoreData.GetModel

local function placeIdApproved(placeId)
	-- TODO: Check if place ID was approved
	return true
end

local function getPlayerData(data, key)
	local teleportData = data[key]
	if teleportData == nil and not RunService:IsStudio() then
		warn("player data does not exist: " .. key)
	end

	return MockPlayer()[key]
end

function Data.GetDungeonData(key)
	-- TODO: Put this in teleport data or a data store
	return MockDungeon[key]
end

function Data.GetPlayerData(player, key)
	-- TODO: Fix this, use data stores
	local joinData = player:GetJoinData()

	if not placeIdApproved(joinData.SourcePlaceId) then
		player:Kick("place id was not approved")
		error("player was from a non approved place")
	end

	return getPlayerData(joinData.TeleportData or {}, key)
end

function Data.GetLocalPlayerData(key)
	-- TODO: Fix this, use data stores
	assert(RunService:IsClient())
	return getPlayerData(TeleportService:GetLocalPlayerTeleportData() or {}, key)
end

return Data
