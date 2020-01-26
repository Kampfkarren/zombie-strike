local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)

local UseSpray = ReplicatedStorage.Remotes.UseSpray

Players.PlayerAdded:connect(function(player)
	UseSpray:FireClient(player, Data.GetPlayerData(player, "Sprays").Equipped)
end)
