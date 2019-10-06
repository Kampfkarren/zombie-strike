local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Promise = require(ReplicatedStorage.Core.Promise)

local dungeonDataStore = DataStoreService:GetDataStore("DungeonInfo")

local DUNGEON_PLACE_ID = 3803533582

local DungeonTeleporter = {}

function DungeonTeleporter.ReserveServer()
	return Promise.promisify(function()
		return TeleportService:ReserveServer(DUNGEON_PLACE_ID)
	end)()
end

function DungeonTeleporter.TeleportPlayers(lobby, accessCode, privateServerId)
	return Promise.promisify(function()
		local playerIds = {}

		for _, player in pairs(lobby.Players) do
			table.insert(playerIds, player.UserId)
		end

		dungeonDataStore:SetAsync(privateServerId, {
			Campaign = lobby.Campaign,
			Difficulty = lobby.Difficulty,
			Hardcore = lobby.Hardcore,
			Members = playerIds,
		})

		TeleportService:TeleportToPrivateServer(
			DUNGEON_PLACE_ID,
			accessCode,
			lobby.Players
		)
	end)()
end

return DungeonTeleporter
