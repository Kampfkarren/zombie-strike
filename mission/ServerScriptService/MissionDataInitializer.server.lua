local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local Loot = require(ReplicatedStorage.Core.Loot)
local Promise = require(ReplicatedStorage.Core.Promise)

local UpdateEquipped = ReplicatedStorage.Remotes.UpdateEquipped

local function numberValue(name, value, playerData)
	local instance = Instance.new("NumberValue")
	instance.Name = name
	instance.Value = value
	instance.Parent = playerData
	return instance
end

Players.PlayerAdded:connect(function(player)
	Promise.all({
		Data.GetPlayerDataAsync(player, "Armor"):andThen(Loot.Serialize),
		Data.GetPlayerDataAsync(player, "Helmet"):andThen(Loot.Serialize),
		Data.GetPlayerDataAsync(player, "Weapon"):andThen(Loot.Serialize),
	}):andThen(function(equipped)
		UpdateEquipped:FireClient(player, unpack(equipped))
	end)

	local playerData = Instance.new("Folder")
	playerData.Name = "PlayerData"

	local level = Data.GetPlayerData(player, "Level")
	numberValue("Level", level, playerData)

	local xp = Data.GetPlayerData(player, "XP")
	numberValue("XP", xp, playerData)

	numberValue("GoldScale", 1, playerData)

	local xpScale = 1
	if os.time() < Data.GetPlayerData(player, "XPExpires") then
		xpScale = 2
	end

	numberValue("XPScale", xpScale, playerData)

	playerData.Parent = player
end)

local function clientDungeonKey(name, type)
	local instance = Instance.new(type or "NumberValue")
	instance.Name = name

	return function(value)
		instance.Value = value
		instance.Parent = ReplicatedStorage.ClientDungeonData
	end
end

clientDungeonKey("Members")(#Dungeon.GetDungeonData("Members"))
clientDungeonKey("Campaign")(Dungeon.GetDungeonData("Campaign"))
clientDungeonKey("Hardcore", "BoolValue")(Dungeon.GetDungeonData("Hardcore"))
