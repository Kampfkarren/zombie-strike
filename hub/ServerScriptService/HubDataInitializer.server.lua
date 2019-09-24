local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local GiveOutfit = require(ServerScriptService.Shared.GiveOutfit)
local Loot = require(ReplicatedStorage.Core.Loot)
local Settings = require(ReplicatedStorage.Core.Settings)

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

	if toEquip.Level > Data.GetPlayerData(player, "Level") then
		warn("equipping item with too high level")
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
	Data.GetPlayerDataAsync(player, name):andThen(function(value)
		local stat = Instance.new("NumberValue")
		stat.Name = name
		stat.Value = value
		stat.Parent = parent

		DataStore2(name, player):OnUpdate(function(value)
			stat.Value = value
		end)
	end)
end

local function initSettings(player, data, refreshCharacter)
	local settingsFolder = Instance.new("Folder")
	settingsFolder.Name = "Settings"

	for _, setting in pairs(Settings.Settings) do
		local value = Settings.GetSettingIndex(setting.Name, player)

		local settingObject = Instance.new("NumberValue")
		settingObject.Name = setting.Name
		settingObject.Value = value
		settingObject.Parent = settingsFolder
	end

	DataStore2("Settings", player):OnUpdate(function(newSettings)
		for settingIndex, setting in pairs(Settings.Settings) do
			settingsFolder[setting.Name].Value = newSettings[settingIndex]
		end

		refreshCharacter()
	end)

	settingsFolder.Parent = data
end

Players.PlayerAdded:connect(function(player)
	local playerData = Instance.new("Folder")
	playerData.Name = "PlayerData"

	initStat(player, "Level", playerData)
	initStat(player, "XP", playerData)
	initStat(player, "Gold", playerData)

	playerData.Parent = player

	local currentMaid, currentRefresh

	local function refreshCharacter()
		if currentMaid then
			currentMaid:DoCleaning()
		end

		if currentRefresh then
			currentRefresh:cancel()
		end

		currentRefresh, currentMaid = GiveOutfit(player, player.Character)
	end

	spawn(function()
		initSettings(player, playerData, refreshCharacter)
	end)

	player.CharacterAdded:connect(refreshCharacter)

	local current, inventoryStore = Data.GetPlayerData(player, "Inventory")
	local function updateInventory(inventory)
		UpdateInventory:FireClient(player, Loot.SerializeTable(inventory))
	end

	inventoryStore:OnUpdate(updateInventory)
	updateInventory(current)

	local function updateEquipment(anUpdate)
		local equippedArmor = Data.GetPlayerData(player, "EquippedArmor")
		local equippedHelmet = Data.GetPlayerData(player, "EquippedHelmet")
		local equippedWeapon = Data.GetPlayerData(player, "EquippedWeapon")

		UpdateEquipment:FireClient(
			player,
			equippedArmor,
			equippedHelmet,
			equippedWeapon
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
