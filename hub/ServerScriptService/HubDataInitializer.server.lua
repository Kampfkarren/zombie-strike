local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local Data = require(ReplicatedStorage.Libraries.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Loot = require(ReplicatedStorage.Core.Loot)
local XP = require(ReplicatedStorage.Core.XP)

local UpdateEquipment = ReplicatedStorage.Remotes.UpdateEquipment
local UpdateInventory = ReplicatedStorage.Remotes.UpdateInventory

DataStore2.Combine(
	"DATA",
	"Inventory",
	"EquippedWeapon",
	"EquippedArmor",
	"EquippedHelmet"
)

UpdateEquipment.OnServerEvent:connect(function(player, equip)
	local inventoryStore = DataStore2("Inventory", player)
	local inventory = inventoryStore:Get(nil, true)
	if not inventory then
		warn("no inventory for equipment")
		return
	end

	local toEquip = inventory[equip]
	if not toEquip then
		warn("toEquip does not exist")
		return
	end

	local equipType
	if toEquip.Type == "Helmet" or toEquip.Type == "Armor" then
		equipType = "Equipped" .. toEquip.Type
	else
		equipType = "EquippedWeapon"
	end

	DataStore2(equipType, player):Set(equip)
end)

Players.PlayerAdded:connect(function(player)
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

	local function characterAdded(character)
		local armor = Data.GetPlayerData(player, "Armor")
		local armorHealth = ArmorScaling.ArmorHealth(armor.Level, armor.Rarity)
		local armorModel = Data.GetModel(armor)

		local helmet = Data.GetPlayerData(player, "Helmet")
		local helmetHealth = ArmorScaling.HelmetHealth(helmet.Level, helmet.Rarity)
		local helmetModel = Data.GetModel(helmet)

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

	local inventoryStore = DataStore2("Inventory", player)
	local function updateInventory(inventory)
		UpdateInventory:FireClient(player, Loot.SerializeTable(inventory))
	end
	inventoryStore:OnUpdate(updateInventory)
	updateInventory(Data.GetPlayerData(player, "Inventory"))

	local function updateEquipment(anUpdate)
		UpdateEquipment:FireClient(
			player,
			Data.GetPlayerData(player, "EquippedArmor"),
			Data.GetPlayerData(player, "EquippedHelmet"),
			Data.GetPlayerData(player, "EquippedWeapon")
		)

		if anUpdate then
			local cframe = player.Character.PrimaryPart.CFrame
			player:LoadCharacter()
			player.Character:SetPrimaryPartCFrame(cframe)
		end
	end

	updateEquipment()
	DataStore2("EquippedArmor", player):OnUpdate(updateEquipment)
	DataStore2("EquippedHelmet", player):OnUpdate(updateEquipment)
	DataStore2("EquippedWeapon", player):OnUpdate(updateEquipment)
end)
