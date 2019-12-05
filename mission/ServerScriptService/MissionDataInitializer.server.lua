local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local Loot = require(ReplicatedStorage.Core.Loot)
local Promise = require(ReplicatedStorage.Core.Promise)

local UpdateEquipped = ReplicatedStorage.Remotes.UpdateEquipped

local VIP_BONUS = 0.2

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

	local goldValue = numberValue("GoldScale", 1, playerData)

	GamePasses.PlayerOwnsPassAsync(player, GamePassDictionary.DoubleGold):andThen(function(owns)
		if owns then
			goldValue.Value = goldValue.Value + 1
		end
	end)

	local xpScale = 1

	if os.time() < Data.GetPlayerData(player, "XPExpires") then
		xpScale = xpScale + 1
	end

	local xpValue = numberValue("XPScale", xpScale, playerData)

	GamePasses.PlayerOwnsPassAsync(player, GamePassDictionary.VIP):andThen(function(vip)
		if vip then
			xpValue.Value = xpValue.Value + VIP_BONUS
		end
	end)

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
