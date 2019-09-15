local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local Data = require(ReplicatedStorage.Core.Data)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local XP = require(ReplicatedStorage.Core.XP)

-- TODO: initialize stuff for LootInfoButton
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

	local armor = Data.GetPlayerData(player, "Armor")
	local armorHealth = ArmorScaling.ArmorHealth(armor.Level, armor.Rarity)
	local armorModel = Data.GetModel(armor)

	local helmet = Data.GetPlayerData(player, "Helmet")
	local helmetHealth = ArmorScaling.HelmetHealth(helmet.Level, helmet.Rarity)
	local helmetModel = Data.GetModel(helmet)

	local function characterAdded(character)
		local health = XP.HealthForLevel(level) + armorHealth + helmetHealth
		character.Humanoid.MaxHealth = health
		character.Humanoid.Health = health

		armorModel.Shirt:Clone().Parent = character
		armorModel.Pants:Clone().Parent = character

		helmetModel.Hat:Clone().Parent = character
	end

	if player.Character then
		characterAdded(player.Character)
	end

	player.CharacterAdded:connect(characterAdded)
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
clientDungeonKey("Hardcore", "BoolValue")(Dungeon.GetDungeonData("Hardcore"))
