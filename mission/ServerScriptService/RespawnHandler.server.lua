local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local DungeonState = require(ServerScriptService.DungeonState)
local OnDied = require(ReplicatedStorage.Core.OnDied)
local PlaceIds = require(ReplicatedStorage.Core.PlaceIds)

local goldScales = {}

local function noRespawns()
	local gamemode = Dungeon.GetDungeonData("Gamemode")
	return (gamemode == "Mission" and Dungeon.GetDungeonData("Hardcore"))
		or (gamemode == "Arena" and ReplicatedStorage:WaitForChild("ArenaLives").Value == 0)
end

ReplicatedStorage.Remotes.RespawnMe.OnServerInvoke = function(player)
	if noRespawns() then return end

	local character = player.Character
	if character and character.Humanoid.Health == 0 then
		coroutine.wrap(function()
			local character = player.CharacterAdded:wait()
			RunService.Heartbeat:wait()

			local currentSpawn = DungeonState.CurrentSpawn

			if currentSpawn:IsA("SpawnLocation") then
				character:MoveTo(currentSpawn.Position)
			else
				character:MoveTo(currentSpawn.WorldPosition)
			end
		end)()

		spawn(function()
			local diff

			if goldScales[player] then
				if goldScales[player] == 5 then
					diff = 0
				else
					diff = -0.1
					goldScales[player] = goldScales[player] + 1
				end
			else
				diff = -0.1
				goldScales[player] = 1
			end

			local GoldScale = player:WaitForChild("PlayerData"):WaitForChild("GoldScale")
			GoldScale.Value = GoldScale.Value + diff
		end)

		player:LoadCharacter()
	end
end

Players.PlayerAdded:connect(function(player)
	player.CharacterAdded:connect(function(character)
		OnDied(character.Humanoid):connect(function()
			wait(2.5)
			if noRespawns() then
				local persist = false

				for _, otherPlayer in pairs(Players:GetPlayers()) do
					local character = otherPlayer.Character
					if character.Humanoid.Health > 0 then
						persist = true
						break
					end
				end

				if not persist then
					for _, player in pairs(Players:GetPlayers()) do
						DataStore2.SaveAllAsync(player):andThen(function()
							TeleportService:Teleport(PlaceIds.GetHubPlace(), player)
						end)
					end
				end
			end
		end)
	end)
end)
