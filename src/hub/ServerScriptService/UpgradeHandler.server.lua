local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Core.Data)
local InventoryUtil = require(ServerScriptService.Libraries.InventoryUtil)
local Loot = require(ReplicatedStorage.Core.Loot)
local PerkUtil = require(ReplicatedStorage.Core.Perks.PerkUtil)
local Upgrades = require(ReplicatedStorage.Core.Upgrades)

local function upgradeBasic(item)
	item.Upgrades = item.Upgrades + 1
end

local function upgradePerk(item, perkId)
	item.Perks[perkId][2] = item.Perks[perkId][2] + 1
end

ReplicatedStorage.Remotes.Upgrade.OnServerEvent:connect(function(player, uuid, perkId)
	local inventory, inventoryStore = Data.GetPlayerData(player, "Inventory")

	local item = InventoryUtil.FindByUuid(inventory, uuid)
	if item == nil then
		warn("player tried to upgrade non existent item!")
		return
	end

	if player:FindFirstChild("Trading") then
		warn("player is trading!")
		return
	end

	local cost, upgrade

	if Loot.IsWeapon(item) then
		local perk = item.Perks[perkId]
		if perk == nil then
			warn("upgrading non-existent perk")
			return
		end

		if perk[2] >= PerkUtil.MAX_PERK_UPGRADES then
			warn("max upgrades for perk")
			return
		end

		cost = Upgrades.CostToUpgradePerk(PerkUtil.DeserializePerks({ perk })[1])
		upgrade = upgradePerk
	elseif Loot.IsWearable(item) then
		if item.Upgrades >= Upgrades.MaxUpgrades then
			warn("max upgrades")
			return
		end

		cost = Upgrades.CostToUpgrade(item)
		upgrade = upgradeBasic
	else
		warn("player not upgrading valid item")
		return
	end

	local gold, goldStore = Data.GetPlayerData(player, "Gold")
	if gold >= cost then
		goldStore:Increment(-cost)

		upgrade(item, perkId)
		inventoryStore:Set(inventory)

		local _, upgradedSomethingStore = Data.GetPlayerData(player, "UpgradedSomething")
		upgradedSomethingStore:Set(true)
	end
end)
