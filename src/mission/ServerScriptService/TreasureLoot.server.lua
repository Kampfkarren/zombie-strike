local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

if Dungeon.GetDungeonData("Gamemode") ~= "Mission" then return end

local GenerateTreasureLoot = require(ServerScriptService.Libraries.GenerateTreasureLoot)
local Loot = require(ReplicatedStorage.Core.Loot)

local SetTreasureLoot = ReplicatedStorage.Remotes.SetTreasureLoot

Players.PlayerAdded:connect(function(player)
	GenerateTreasureLoot:andThen(function(loot)
		if not loot then return end
		local serialized = Loot.Serialize(loot)
		SetTreasureLoot:FireClient(player, serialized)
	end)
end)
