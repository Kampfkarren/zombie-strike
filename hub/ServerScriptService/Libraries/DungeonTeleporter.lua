local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local PlaceIds = require(ReplicatedStorage.Core.PlaceIds)
local Promise = require(ReplicatedStorage.Core.Promise)

local dungeonDataStore = DataStoreService:GetDataStore("DungeonInfo")

local DungeonTeleporter = {}

function DungeonTeleporter.ReserveServer()
	return Promise.promisify(function()
		local startTime = tick()
		local accessCode, privateServerId = TeleportService:ReserveServer(PlaceIds.GetMissionPlace())
		print("🕴Reserve server took", tick() - startTime, "seconds")
		return accessCode, privateServerId
	end)()
end

function DungeonTeleporter.TeleportPlayers(lobby, accessCode, privateServerId, loadingScreen)
	return Promise.promisify(function()
		local playerIds = {}

		for _, player in pairs(lobby.Players) do
			table.insert(playerIds, player.UserId)
		end

		local startTime = tick()
		dungeonDataStore:SetAsync(privateServerId, {
			Campaign = lobby.Campaign,
			Difficulty = lobby.Difficulty,
			Hardcore = lobby.Hardcore,
			Members = playerIds,
		})
		print("🕴Setting dungeon data store took", tick() - startTime, "seconds")

		TeleportService:TeleportToPrivateServer(
			PlaceIds.GetMissionPlace(),
			accessCode,
			lobby.Players,
			nil,
			nil,
			loadingScreen
		)
	end)()
end

return DungeonTeleporter
