local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Data = require(ReplicatedStorage.Core.Data)

local spawnLocation

Players.PlayerAdded:connect(function(player)
	Data.GetPlayerData(player, "Level")
	if player:IsDescendantOf(game) then
		player:LoadCharacter()

		if spawnLocation == nil then
			spawnLocation = Workspace:FindFirstChild("SpawnLocation", true)
		end

		RunService.Heartbeat:wait()

		local x, y, z = (spawnLocation.CFrame - spawnLocation.Position):ToEulerAnglesXYZ()
		print(x, y, z)

		player.Character:SetPrimaryPartCFrame(
			CFrame.new(player.Character.PrimaryPart.Position)
			* CFrame.Angles(z, y, x)
		)
	end
end)
