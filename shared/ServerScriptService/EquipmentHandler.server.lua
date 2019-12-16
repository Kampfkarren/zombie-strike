local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local EquipmentUtil = require(ReplicatedStorage.Core.EquipmentUtil)
local WeakInstanceTable = require(ReplicatedStorage.Core.WeakInstanceTable)

local UpdateEquipmentInventory = ReplicatedStorage.Remotes.UpdateEquipmentInventory

local healthPackCooldowns = WeakInstanceTable()
local grenadeCooldowns = WeakInstanceTable()

local function alwaysTrue()
	return true
end

local function hookRemote(name, getEquipped, cooldowns)
	ReplicatedStorage.Remotes["Use" .. name].OnServerInvoke = function(player)
		local character = player.Character
		if not character or character.Humanoid.Health <= 0 then return end

		local equipped = getEquipped(player)

		if tick() - (cooldowns[player] or 0) >= equipped.Cooldown then
			if (equipped.CanUse or alwaysTrue)(player) then
				cooldowns[player] = tick()
				return equipped.ServerEffect(player):awaitValue()
			end
		end
	end
end

hookRemote("Grenade", EquipmentUtil.GetGrenade, grenadeCooldowns)
hookRemote("HealthPack", EquipmentUtil.GetHealthPack, healthPackCooldowns)

if ReplicatedStorage.HubWorld.Value then
	Players.PlayerAdded:connect(function(player)
		local equipmentInventory, equipmentInventoryStore = Data.GetPlayerData(player, "Equipment")

		local function updateEquipmentInventory(inventory)
			UpdateEquipmentInventory:FireClient(player, inventory)
		end

		equipmentInventoryStore:OnUpdate(updateEquipmentInventory)
		updateEquipmentInventory(equipmentInventory)
	end)

	UpdateEquipmentInventory.OnServerEvent:connect(function(player, typeCode, index)
		local equipmentType = typeCode == 1 and "HealthPack" or "Grenade"
		local equipmentInventory = Data.GetPlayerData(player, "Equipment")[equipmentType]

		if table.find(equipmentInventory, index) == nil then
			warn("UpdateEquipmentInventory: player does not own equipment")
			return
		end

		DataStore2("Equipped" .. equipmentType, player):Set(index)
	end)
end
