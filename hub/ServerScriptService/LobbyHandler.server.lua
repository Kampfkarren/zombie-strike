local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Lobby = require(ReplicatedStorage.Libraries.Lobby)
local Promise = require(ReplicatedStorage.Core.Promise)

local PatchLobby = ReplicatedStorage.Remotes.PatchLobby
local UpdateLobbies = ReplicatedStorage.Remotes.UpdateLobbies

local DUNGEON_PLACE_ID = 3803533582

local dungeonDataStore = DataStoreService:GetDataStore("DungeonInfo")
local lobbies = {}
local unique = 0

local function getPlayerLobby(player)
	for lobbyIndex, lobby in pairs(lobbies) do
		for spot, otherPlayer in pairs(lobby.Players) do
			if otherPlayer == player then
				return lobby, lobbyIndex, spot
			end
		end
	end
end

ReplicatedStorage.Remotes.CreateLobby.OnServerInvoke = function(
	player,
	campaignIndex,
	difficultyIndex,
	public,
	hardcore
)
	local campaign = Campaigns[campaignIndex]
	if not campaign then
		warn("invalid campaign", campaignIndex)
		return
	end

	local difficulty = campaign.Difficulties[difficultyIndex]
	if not difficulty then
		warn("invalid difficulty", difficultyIndex)
		return
	end

	local level = Data.GetPlayerData(player, "Level")
	if level < difficulty.MinLevel then
		warn("too low level for difficulty")
		return
	end

	local lobby = getPlayerLobby(player)
	if lobby then
		warn("player already in lobby")
		return
	end

	unique = unique + 1

	local lobby = {
		Players = { player },
		Campaign = campaignIndex,
		Difficulty = difficultyIndex,
		Public = public == true,
		Hardcore = hardcore == true,
		Unique = unique,
		Kicked = {},
	}

	table.insert(lobbies, lobby)

	PatchLobby:FireAllClients(#lobbies, Lobby.Serialize(lobby))

	return true
end

ReplicatedStorage.Remotes.JoinLobby.OnServerInvoke = function(player, lobbyIndex)
	local lobby = lobbies[lobbyIndex]
	if not lobby then
		warn("invalid lobby index")
		return
	end

	if lobby.Kicked[player] then
		warn("joined while kicked")
		return
	end

	if #lobby.Players == 4 then
		warn("full lobby")
		return
	end

	for _, otherPlayer in pairs(lobby.Players) do
		if player == otherPlayer then
			warn("already in lobby")
			return
		end
	end

	local campaign = assert(Campaigns[lobby.Campaign])
	local difficulty = assert(campaign.Difficulties[lobby.Difficulty])

	local playerLevel = Data.GetPlayerData(player, "Level")

	if difficulty.MinLevel < playerLevel then
		warn("level too low")
		return
	end

	table.insert(lobby.Players, player)
	PatchLobby:FireAllClients(lobbyIndex, Lobby.Serialize(lobby))

	return true
end

ReplicatedStorage.Remotes.LeaveLobby.OnServerEvent:connect(function(player)
	local lobby, lobbyIndex, spot = getPlayerLobby(player)
	if not lobby then
		warn("LeaveLobby without a lobby")
		return
	end

	-- TODO: Shouldn't be able to leave while teleporting

	table.remove(lobby.Players, spot)

	if #lobby.Players == 0 then
		table.remove(lobbies, lobbyIndex)
		PatchLobby:FireAllClients(lobbyIndex)
	else
		PatchLobby:FireAllClients(lobbyIndex, Lobby.Serialize(lobby))
	end
end)

ReplicatedStorage.Remotes.KickFromLobby.OnServerEvent:connect(function(player, kickPlayer)
	local lobby, lobbyIndex = getPlayerLobby(player)
	if not lobby then
		warn("KickFromLobby without a lobby")
		return
	end

	for spot, otherPlayer in pairs(lobby.Players) do
		if otherPlayer == kickPlayer then
			table.remove(lobby.Players, spot)
			lobby.Kicked[kickPlayer] = true
			ReplicatedStorage.Remotes.KickFromLobby:FireClient(kickPlayer, lobbyIndex)

			if #lobby.Players == 0 then
				table.remove(lobbies, lobbyIndex)
				PatchLobby:FireAllClients(lobbyIndex)
			else
				PatchLobby:FireAllClients(lobbyIndex, Lobby.Serialize(lobby))
			end
		end
	end
end)

ReplicatedStorage.Remotes.PlayLobby.OnServerEvent:connect(function(player)
	local lobby = getPlayerLobby(player)
	if not lobby then
		warn("PlayLobby without a lobby")
		return
	end

	if lobby.Players[1] ~= player then
		warn("PlayLobby but not owner")
		return
	end

	for _, player in pairs(lobby.Players) do
		ReplicatedStorage.Remotes.PlayLobby:FireClient(player, true)
	end

	local playerPromises = {}

	for _, player in pairs(lobby.Players) do
		if player:IsDescendantOf(game) then
			table.insert(playerPromises, Promise.new(function(resolve, reject)
				coroutine.wrap(function()
					local success, result = pcall(function()
						DataStore2.SaveAll(player)
					end)

					if not success then
						reject(result)
					else
						resolve()
					end
				end)()
			end))
		end
	end

	Promise.all({
		Promise.new(function(resolve, reject)
			coroutine.wrap(function()
				local success, result, privateServerId = pcall(function()
					return TeleportService:ReserveServer(DUNGEON_PLACE_ID)
				end)

				if not success then
					reject("Couldn't reserve a server: " .. result)
				else
					resolve({ result, privateServerId })
				end
			end)()
		end),
		unpack(playerPromises),
	}):andThen(function(results)
		return Promise.new(function(resolve, reject)
			coroutine.wrap(function()
				local success, result = pcall(function()
					local accessCode, privateServerId = unpack(results[1])
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
				end)

				if success then
					resolve()
				else
					reject(result)
				end
			end)()
		end)
	end):catch(function(problem)
		ReplicatedStorage.Remotes.PlayLobby:FireClient(player, false, problem)
	end)

	-- DUNGEON_PLACE_ID
end)

Players.PlayerAdded:connect(function(player)
	UpdateLobbies:FireClient(player, Lobby.SerializeTable(lobbies))
end)
