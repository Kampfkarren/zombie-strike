local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local ZombiePassDictionary = require(ReplicatedStorage.Core.ZombiePassDictionary)
local ZombiePassRewards = require(ServerScriptService.Shared.ZombiePassRewards)

local ZombiePass = ReplicatedStorage.Remotes.ZombiePass

Players.PlayerAdded:connect(function(player)
	local zombiePass, zombiePassStore = Data.GetPlayerData(player, "ZombiePass")
	local rewards

	local currentLevel = ZombiePassDictionary[zombiePass.Level]
	if currentLevel and zombiePass.XP >= currentLevel.GamesNeeded then
		rewards = { zombiePass.Level }
		ZombiePassRewards.GrantRewards(player, rewards)
		zombiePass.Level = zombiePass.Level + 1
		zombiePass.XP = 0

		zombiePassStore:Set(zombiePass)

		DataStore2.SaveAllAsync(player)
	end

	ZombiePass:FireClient(player, zombiePass.Level, zombiePass.XP, zombiePass.Premium, rewards)
end)
