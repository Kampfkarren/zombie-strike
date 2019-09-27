local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local Data = require(ReplicatedStorage.Core.Data)

local UpdateCosmetics = ReplicatedStorage.Remotes.UpdateCosmetics

Players.PlayerAdded:connect(function(player)
	local data = Data.GetPlayerData(player, "Cosmetics")
	UpdateCosmetics:FireClient(player, data.Owned, data.Equipped)
end)
