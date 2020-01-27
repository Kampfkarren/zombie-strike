local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ArenaConstants = require(ReplicatedStorage.Core.ArenaConstants)
local ArenaDifficulty = require(ReplicatedStorage.Libraries.ArenaDifficulty)
local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local DungeonTeleporter = require(ServerScriptService.Libraries.DungeonTeleporter)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local Friends = require(ReplicatedStorage.Libraries.Friends)
local GetCurrentBoss = require(ReplicatedStorage.Libraries.GetCurrentBoss)
local inspect = require(ReplicatedStorage.Core.inspect)
local Promise = require(ReplicatedStorage.Core.Promise)
local t = require(ReplicatedStorage.Vendor.t)

local Lobbies = ReplicatedStorage.Lobbies

local HACKER_FAIL_URL = "CENSORED URL

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
			if lobby.Instance:FindFirstChild("Countdown") then
				lobby.Instance.Countdown.Value = number
			end

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

local function removeLobby(unique)
	for index, lobby in pairs(lobbies) do
		if lobby.Unique == unique then
			table.remove(lobbies, index)
			return
		end
	end
end

local validateLobby = t.intersection(
	t.interface({
		Campaign = t.intersection(t.integer, t.numberConstrained(1, #Campaigns)),
		Public = t.boolean,
	}),

	t.union(
		t.interface({
			Gamemode = t.literal("Arena"),
			Level = t.intersection(t.integer, function(level)
				return level == 1
					or level % ArenaConstants.LevelStep == 0
					and level <= ArenaConstants.MaxLevel
					and level > 0
			end),
		}),

		t.interface({
			Gamemode = t.literal("Mission"),
			Difficulty = t.integer, -- We can't constrain this here
			Hardcore = t.boolean,
		}),

		t.interface({
			Gamemode = t.literal("Boss"),
			Hardcore = t.boolean,
		})
	)
)

ReplicatedStorage.Remotes.CreateLobby.OnServerInvoke = function(player, info)
	local success, problem = validateLobby(info)
	if not success then
		warn("CreateLobby: validation error: " .. problem .. " / " .. inspect(info))

		local epicFails, epicFailsStore = Data.GetPlayerData(player, "EpicFails")
		if not epicFails.CreateLobby then
			local oldValue = typeof(info) == "number"

			epicFails.CreateLobby = oldValue and 1 or 2
			epicFailsStore:Set(epicFails)

			FastSpawn(function()
				local message = ("**%s** just tried to create a hacked lobby! FAIL! %s"):format(
					player.Name,
					problem
				)

				local messageWithContent = message .. "\n" .. require(ReplicatedStorage.Core.inspect)(info)

				if oldValue then
					message = message .. "\nAND it was a number, the old system! DOUBLE FAIL! " .. info
				elseif #messageWithContent <= 2000 then
					message = messageWithContent
				end

				HttpService:PostAsync(
					HACKER_FAIL_URL,
					HttpService:JSONEncode({
						content = message,
					})
				)
			end)
		end

		return
	end

	local campaign = Campaigns[info.Campaign]
	if not campaign then
		warn("CreateLobby: invalid campaign (should be unreachable?)", info.Campaign)
		return
	end

	local lobbyInstance = Instance.new("Folder")
	value(lobbyInstance, "StringValue", "Gamemode", info.Gamemode)
	value(lobbyInstance, "NumberValue", "Campaign", info.Campaign)
	value(lobbyInstance, "BoolValue", "Public", info.Public)
	value(lobbyInstance, "BoolValue", "Hardcore", info.Hardcore)

	local lobby = {
		Players = { player },
		Campaign = info.Campaign,
		Gamemode = info.Gamemode,
		Public = info.Public,
		Kicked = {},
		Instance = lobbyInstance,
	}

	local playerLevel = Data.GetPlayerData(player, "Level")

	if info.Gamemode == "Mission" then
		local difficulty = campaign.Difficulties[info.Difficulty]
		if not difficulty then
			warn("CreateLobby: invalid difficulty", info.Difficulty)
			return
		end

		if playerLevel < difficulty.MinLevel then
			warn("CreateLobby: too low level for difficulty")
			return
		end

		lobby.Difficulty = info.Difficulty
		value(lobbyInstance, "NumberValue", "Difficulty", info.Difficulty)

		lobby.Hardcore = info.Hardcore
		value(lobbyInstance, "BoolValue", "Hardcore", info.Hardcore)
	elseif info.Gamemode == "Arena" then
		lobby.ArenaLevel = info.Level
		value(lobbyInstance, "NumberValue", "Level", info.Level)
	elseif info.Gamemode == "Boss" then
		lobby.Boss = GetCurrentBoss().Index
		value(lobbyInstance, "NumberValue", "Boss", lobby.Boss)
	end

	if getPlayerLobby(player) then
		warn("CreateLobby: player already in lobby")
		return
	end

	if teleporting[player] then
		warn("CreateLobby: player already teleporting")
		return
	end

	unique = unique + 1
	lobby.Unique = unique

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
	local difficulty
	if lobby.Gamemode == "Arena" then
		difficulty = ArenaDifficulty(lobby.ArenaLevel)
	elseif lobby.Gamemode ~= "Boss" then
		difficulty = campaign.Difficulties[lobby.Difficulty]
	end

	local playerLevel = Data.GetPlayerData(player, "Level")

	if difficulty and difficulty.MinLevel > playerLevel then
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

local function leaveLobby(player, dontWarn)
	local lobby, _, spot = getPlayerLobby(player)
	if not lobby then
		if not dontWarn then
			warn("LeaveLobby without a lobby")
		end

		return
	end

	if lobby.Teleporting then
		if not dontWarn then
			warn("LeaveLobby while teleporting")
		end

		return
	end

	table.remove(lobby.Players, spot)

	if #lobby.Players == 0 then
		removeLobby(lobby.Unique)
		lobby.Instance:Destroy()
	else
		lobby.Instance.Players[player.UserId]:Destroy()
		lobby.Instance.Owner.Value = lobby.Players[1]
		if lobby.Promise then
			lobby.Promise:cancel()
		end
	end
end

ReplicatedStorage.Remotes.LeaveLobby.OnServerEvent:connect(leaveLobby)

ReplicatedStorage.Remotes.KickFromLobby.OnServerEvent:connect(function(player, kickPlayer)
	local lobby = getPlayerLobby(player)
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
				removeLobby(lobby.Unique)
				lobby.Instance:Destroy()
			else
				lobby.Instance.Players[kickPlayer.UserId]:Destroy()
				lobby.Instance.Owner.Value = lobby.Players[1]
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
			removeLobby(lobby.Unique)
			lobby.Instance:Destroy()
		end):catch(function(problem)
			ReplicatedStorage.Remotes.PlayLobby:FireClient(player, false, problem)
		end):finally(function()
			if lobby.Instance:FindFirstChild("Countdown") then
				lobby.Instance.Countdown.Value = 0
				lobby.Teleporting = false
				lobby.Promise = nil

				for _, player in pairs(lobby.Players) do
					teleporting[player] = nil
					ReplicatedStorage.Remotes.Teleporting:FireClient(player, false)
				end
			end
		end)
end)

Players.PlayerRemoving:connect(function(player)
	teleporting[player] = nil
	leaveLobby(player, true)
end)
