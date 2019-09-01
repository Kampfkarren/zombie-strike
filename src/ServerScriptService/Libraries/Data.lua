local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local MockData = ServerScriptService.MockData

local MockPlayer = require(MockData.MockPlayer)

local Data = {}

local function placeIdApproved(placeId)
	-- TODO: Check if place ID was approved
	return true
end

function Data.GetPlayerData(player, key)
	local joinData = player:GetJoinData()

	if not placeIdApproved(joinData.SourcePlaceId) then
		player:Kick("place id was not approved")
		error("player was from a non approved place")
	end

	local teleportData = (joinData.TeleportData or {})[key]
	if teleportData == nil and not RunService:IsStudio() then
		warn("player data does not exist: " .. key)
	end

	return MockPlayer[key]
end

return Data
