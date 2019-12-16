local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")

local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local DungeonTeleporter = require(ServerScriptService.Libraries.DungeonTeleporter)
local GiveOutfit = require(ServerScriptService.Shared.GiveOutfit)
local Loot = require(ReplicatedStorage.Core.Loot)
local Settings = require(ReplicatedStorage.Core.Settings)
local TeleportScreen = require(ReplicatedStorage.Libraries.TeleportScreen)

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

Players.PlayerAdded:connect(function(player)
	local playerData = Instance.new("Folder")
	playerData.Name = "PlayerData"

	initStat(player, "Level", playerData)
	initStat(player, "XP", playerData)
	initStat(player, "Gold", playerData)
	initStat(player, "Brains", playerData)
	initStat(player, "DungeonsPlayed", playerData)
	initStat(player, "EquippedGrenade", playerData)
	initStat(player, "EquippedHealthPack", playerData)

	playerData.Parent = player

	local updateOutfit, currentRefresh
	local refreshing = false

	local function refreshCharacter()
		if not player.Character then return end
		if not updateOutfit then return end

		if currentRefresh then
			currentRefresh:cancel()
		end

		currentRefresh = updateOutfit:andThen(function(refresh)
			if refreshing then return end
			refreshing = true
			coroutine.wrap(function()
				RunService.Heartbeat:wait()
				refreshing = false
				refresh()
			end)()
		end)
	end

	player.CharacterAdded:connect(function(character)
		updateOutfit = GiveOutfit(player, character)
		updateOutfit:andThen(function(refresh)
			refresh()
		end)

		character.Humanoid.Died:connect(function()
			wait(1)
			player:LoadCharacter()
		end)
	end)

	Data.GetPlayerDataAsync(player, "DungeonsPlayed"):andThen(function(played)
		if played == 0 then
			DungeonTeleporter.ReserveServer()
				:andThen(function(accessCode, privateServerId)
					local gui = StarterGui.TeleportGui:Clone()
					gui.Enabled = true

					local lobby = {
						Gamemode = "Mission",
						Players = { player },
						Campaign = 1,
						Difficulty = 1,
						Hardcore = false,
					}

					TeleportScreen(gui, lobby)

					return DungeonTeleporter.TeleportPlayers(lobby, accessCode, privateServerId, gui)
				end)
				:catch(function(error)
					warn("Couldn't teleport noob to the dungeon: " .. error)
					spawn(function()
						player:LoadCharacter()
					end)
				end)
		else
			player:LoadCharacter()
		end
	end)

	Settings.HookSetting("Gold Guns", refreshCharacter, player)
	Settings.HookSetting("Skin Tone", refreshCharacter, player)

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

	local current, inventoryStore = Data.GetPlayerData(player, "Inventory")
	local function updateInventory(inventory)
		-- print(require(game.ReplicatedStorage.Core.inspect)(inventory))
		UpdateInventory:FireClient(player, Loot.SerializeTable(inventory))
		updateEquipment()
	end

	inventoryStore:OnUpdate(function(inventory)
		updateInventory(inventory)
		refreshCharacter()
	end)
	updateInventory(current)

	updateEquipment()

	for equipped in pairs(Data.Equippable) do
		DataStore2("Equipped" .. equipped, player):OnUpdate(updateEquipment)
	end

	DataStore2("Cosmetics", player):OnUpdate(refreshCharacter)
end)
