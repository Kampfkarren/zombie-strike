local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local Data = require(ReplicatedStorage.Libraries.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Loot = require(ReplicatedStorage.Core.Loot)
local XP = require(ReplicatedStorage.Core.XP)

local UpdateEquipment = ReplicatedStorage.Remotes.UpdateEquipment
local UpdateInventory = ReplicatedStorage.Remotes.UpdateInventory

-- DataStore2.Combine(
-- 	"DATA",
-- 	"Inventory",
-- 	"EquippedWeapon",
-- 	"EquippedArmor",
-- 	"EquippedHelmet"
-- )

UpdateEquipment.OnServerEvent:connect(function(player, equip)
	local inventory = Data.GetPlayerData(player, "Inventory")

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

local function initStat(player, name, parent)
	local value = Data.GetPlayerData(player, name)
	local stat = Instance.new("NumberValue")
	stat.Name = name
	stat.Value = value
	stat.Parent = parent

	DataStore2(name, player):OnUpdate(function(value)
		stat.Value = value
	end)

	return value
end

Players.PlayerAdded:connect(function(player)
	local playerData = Instance.new("Folder")
	playerData.Name = "PlayerData"

	local level = initStat(player, "Level", playerData)
	initStat(player, "XP", playerData)
	initStat(player, "Gold", playerData)

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

	local function refreshCharacter()
		local cframe = player.Character.PrimaryPart.CFrame
		player:LoadCharacter()
		player.Character:SetPrimaryPartCFrame(cframe)
	end

	local current, inventoryStore = Data.GetPlayerData(player, "Inventory")
	local function updateInventory(inventory)
		UpdateInventory:FireClient(player, Loot.SerializeTable(inventory))
		refreshCharacter()
	end
	inventoryStore:OnUpdate(updateInventory)
	updateInventory(current)

	local function updateEquipment(anUpdate)
		UpdateEquipment:FireClient(
			player,
			Data.GetPlayerData(player, "EquippedArmor"),
			Data.GetPlayerData(player, "EquippedHelmet"),
			Data.GetPlayerData(player, "EquippedWeapon")
		)

		if anUpdate then
			ServerStorage.EquipmentUpdated:Fire(player)
			refreshCharacter()
		end
	end

	updateEquipment()

	for equipped in pairs(Data.Equippable) do
		DataStore2("Equipped" .. equipped, player):OnUpdate(updateEquipment)
	end
end)