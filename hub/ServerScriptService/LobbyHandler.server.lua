local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local DungeonTeleporter = require(ServerScriptService.Libraries.DungeonTeleporter)
local Friends = require(ReplicatedStorage.Libraries.Friends)
local Promise = require(ReplicatedStorage.Core.Promise)

local Lobbies = ReplicatedStorage.Lobbies

local lobbies = {}
local teleporting = {}
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

local function findLobbyByUnique(unique)
	for _, lobby in pairs(lobbies) do
		if lobby.Unique == unique then
			return lobby
		end
	end
end

local function countdown(lobby, number)
	return function()
		return Promise.new(function(resolve)
			lobby.Instance.Countdown.Value = number

			delay(1, resolve)
		end)
	end
end

local function value(parent, class, name, value)
	local object = Instance.new(class)
	object.Name = name
	object.Value = value
	object.Parent = parent
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

	if teleporting[player] then
		warn("player already teleporting")
		return
	end

	unique = unique + 1

	local lobbyInstance = Instance.new("Folder")
	value(lobbyInstance, "NumberValue", "Campaign", campaignIndex)
	value(lobbyInstance, "NumberValue", "Difficulty", difficultyIndex)
	value(lobbyInstance, "BoolValue", "Public", public == true)
	value(lobbyInstance, "BoolValue", "Hardcore", hardcore == true)
	value(lobbyInstance, "NumberValue", "Unique", unique)
	value(lobbyInstance, "ObjectValue", "Owner", player)
	value(lobbyInstance, "NumberValue", "Countdown", 0)

	local players = Instance.new("Folder")
	players.Name = "Players"

	local playerValue = Instance.new("ObjectValue")
	playerValue.Name = player.UserId
	playerValue.Value = player
	playerValue.Parent = players

	players.Parent = lobbyInstance
	lobbyInstance.Parent = Lobbies

	local lobby = {
		Players = { player },
		Campaign = campaignIndex,
		Difficulty = difficultyIndex,
		Public = public == true,
		Hardcore = hardcore == true,
		Unique = unique,
		Kicked = {},
		Instance = lobbyInstance,
	}

	table.insert(lobbies, lobby)

	return true
end

-- We found Lobby's racist tweets from 2014 :/
ReplicatedStorage.Remotes.CancelLobby.OnServerEvent:connect(function(player)
	local lobby = getPlayerLobby(player)
	if not lobby then
		warn("CancelLobby: no lobby")
		return
	end

	if lobby.Players[1] ~= player then
		warn("CancelLobby: player tried to cancel lobby they didn't own")
		return
	end

	if lobby.Teleporting then
		warn("CancelLobby: already teleporting, too late")
		return
	end

	if lobby.Promise then
		lobby.Promise:cancel()
	end
end)

ReplicatedStorage.Remotes.JoinLobby.OnServerInvoke = function(player, unique)
	local lobby = findLobbyByUnique(unique)
	if not lobby then
		warn("invalid lobby index")
		return
	end

	if lobby.Kicked[player] then
		warn("joined while kicked")
		return
	end

	if lobby.Promise then
		warn("lobby is teleporting")
		return
	end

	if #lobby.Players == 4 then
		warn("full lobby")
		return
	end

	if getPlayerLobby(player) then
		warn("already in lobby")
		return
	end

	if not lobby.Public and not Friends.IsFriendsWith(player, lobby.Players[1]) then
		warn("not friends with owner in private lobby")
		return
	end

	local campaign = assert(Campaigns[lobby.Campaign])
	local difficulty = assert(campaign.Difficulties[lobby.Difficulty])

	local playerLevel = Data.GetPlayerData(player, "Level")

	if difficulty.MinLevel > playerLevel then
		warn("level too low")
		return
	end

	table.insert(lobby.Players, player)

	local playerRepresentation = Instance.new("ObjectValue")
	playerRepresentation.Name = player.UserId
	playerRepresentation.Value = player
	playerRepresentation.Parent = lobby.Instance.Players

	return true
end

ReplicatedStorage.Remotes.LeaveLobby.OnServerEvent:connect(function(player)
	local lobby, lobbyIndex, spot = getPlayerLobby(player)
	if not lobby then
		warn("LeaveLobby without a lobby")
		return
	end

	if lobby.Teleporting then
		warn("LeaveLobby while teleporting")
		return
	end

	table.remove(lobby.Players, spot)

	if #lobby.Players == 0 then
		table.remove(lobbies, lobbyIndex)
		lobby.Instance:Destroy()
	else
		lobby.Instance.Players[player.UserId]:Destroy()
		lobby.Instance.Owner.Value = lobby.Players[1]
		if lobby.Promise then
			lobby.Promise:cancel()
		end
	end
end)

ReplicatedStorage.Remotes.KickFromLobby.OnServerEvent:connect(function(player, kickPlayer)
	local lobby, lobbyIndex = getPlayerLobby(player)
	if not lobby then
		warn("KickFromLobby without a lobby")
		return
	end

	if teleporting[player] then
		warn("KickFromLobby while teleporting")
		return
	end

	for spot, otherPlayer in pairs(lobby.Players) do
		if otherPlayer == kickPlayer then
			table.remove(lobby.Players, spot)
			lobby.Kicked[kickPlayer] = true
			ReplicatedStorage.Remotes.KickFromLobby:FireClient(kickPlayer, lobby.Unique)

			if #lobby.Players == 0 then
				table.remove(lobbies, lobbyIndex)
				lobby.Instance:Destroy()
			else
				lobby.Instance.Players[kickPlayer.UserId]:Destroy()
				lobby.Instance.Owner.Value = lobby.Players[1]
			end
		end
	end
end)

ReplicatedStorage.Remotes.PlayLobby.OnServerEvent:connect(function(player)
	local lobby, lobbyIndex = getPlayerLobby(player)
	if not lobby then
		warn("PlayLobby without a lobby")
		return
	end

	if teleporting[player] then
		warn("PlayLobby, already teleporting")
		return
	end

	if lobby.Players[1] ~= player then
		warn("PlayLobby but not owner")
		return
	end

	local playerPromises = {}

	for _, player in pairs(lobby.Players) do
		if player:IsDescendantOf(game) then
			teleporting[player] = true

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

	lobby.Promise = countdown(lobby, 3)()
		:andThen(countdown(lobby, 2))
		:andThen(countdown(lobby, 1))
		:andThen(function()
			lobby.Teleporting = true

			return Promise.all({
				DungeonTeleporter.ReserveServer():andThen(function(accessCode, privateServerId)
					return { accessCode, privateServerId }
				end):catch(function(result)
					return Promise.reject("Couldn't reserve a server: " .. result)
				end),
				unpack(playerPromises),
			})
		end):andThen(function(results)
			for _, player in pairs(lobby.Players) do
				ReplicatedStorage.Remotes.Teleporting:FireClient(player, true)
			end

			return DungeonTeleporter.TeleportPlayers(lobby, unpack(results[1]))
		end):andThen(function()
			table.remove(lobbies, lobbyIndex)
			lobby.Instance:Destroy()
		end):catch(function(problem)
			ReplicatedStorage.Remotes.PlayLobby:FireClient(player, false, problem)
		end):finally(function()
			lobby.Instance.Countdown.Value = 0
			lobby.Teleporting = false
			lobby.Promise = nil

			for _, player in pairs(lobby.Players) do
				teleporting[player] = nil
				ReplicatedStorage.Remotes.Teleporting:FireClient(player, false)
			end
		end)
end)

Players.PlayerRemoving:connect(function(player)
	teleporting[player] = nil
end)
