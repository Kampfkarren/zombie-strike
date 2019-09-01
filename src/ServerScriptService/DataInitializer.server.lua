local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ServerScriptService.Libraries.Data)
local XP = require(ReplicatedStorage.Libraries.XP)

Players.PlayerAdded:connect(function(player)
	-- TODO: This won't work with levels changing in game
	local playerData = Instance.new("Folder")
	playerData.Name = "PlayerData"

	local level = Data.GetPlayerData(player, "Level")
	local levelStat = Instance.new("NumberValue")
	levelStat.Name = "Level"
	levelStat.Value = level
	levelStat.Parent = playerData

	local xp = Data.GetPlayerData(player, "XP")
	local xpStat = Instance.new("NumberValue")
	xpStat.Name = "XP"
	xpStat.Value = xp
	xpStat.Parent = playerData

	playerData.Parent = player

	player.CharacterAdded:connect(function(character)
		local health = XP.HealthForLevel(level)
		character.Humanoid.MaxHealth = health
		character.Humanoid.Health = health
	end)
end)
