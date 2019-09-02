local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local MockData = ReplicatedStorage.MockData

local MockDungeon = require(MockData.MockDungeon)
local MockPlayer = require(MockData.MockPlayer)

local Data = {}

local function placeIdApproved(placeId)
	-- TODO: Check if place ID was approved
	return true
end

local function getPlayerData(data, key)
	local teleportData = data[key]
	if teleportData == nil and not RunService:IsStudio() then
		warn("player data does not exist: " .. key)
	end

	return MockPlayer[key]
end

function Data.GetDungeonData(key)
	-- TODO: How to give the server this information?
	-- Can be done by giving it to the players in their teleport data
	-- Or with MessagingService
	-- POSSIBLY with DataStoreService, although I'm scared of that
	return MockDungeon[key]
end

function Data.GetPlayerData(player, key)
	local joinData = player:GetJoinData()

	if not placeIdApproved(joinData.SourcePlaceId) then
		player:Kick("place id was not approved")
		error("player was from a non approved place")
	end

	return getPlayerData(joinData.TeleportData or {}, key)
end

function Data.GetLocalPlayerData(key)
	assert(RunService:IsClient())
	return getPlayerData(TeleportService:GetLocalPlayerTeleportData() or {}, key)
end

function Data.GetModel(data)
	return ReplicatedStorage.Items[data.Type .. data.Model]:Clone()
end

return Data
