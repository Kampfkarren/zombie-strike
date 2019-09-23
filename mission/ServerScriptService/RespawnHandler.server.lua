local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local DungeonState = require(ServerScriptService.DungeonState)

local HUB_PLACE = 3759927663

local goldScales = {}

ReplicatedStorage.Remotes.RespawnMe.OnServerInvoke = function(player)
	if Dungeon.GetDungeonData("Hardcore") then return end

	local character = player.Character
	if character and character.Humanoid.Health == 0 then
		coroutine.wrap(function()
			local character = player.CharacterAdded:wait()
			RunService.Heartbeat:wait()
			character:MoveTo(DungeonState.CurrentSpawn.WorldPosition)
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
		if Dungeon.GetDungeonData("Hardcore") then
			character.Humanoid.Died:connect(function()
				wait(2.5)
				TeleportService:Teleport(HUB_PLACE, player)
			end)
		end
	end)
end)
