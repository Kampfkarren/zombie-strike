local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cosmetics = require(ReplicatedStorage.Cosmetics)
local Data = require(ReplicatedStorage.Core.Data)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local Loot = require(ReplicatedStorage.Core.Loot)
local Rodux = require(ReplicatedStorage.Vendor.Rodux)

local Store

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

Store = Rodux.Store.new(Rodux.combineReducers({
	equipment = Rodux.createReducer(nil, {
		UpdateEquipment = function(_, action)
			local armor, helmet, weapon = action.newArmor, action.newHelmet, action.newWeapon
			local currentInventory = assert(Store:getState().inventory)

			Data.SetLocalPlayerData("EquippedArmor", armor)
			Data.SetLocalPlayerData("EquippedHelmet", helmet)
			Data.SetLocalPlayerData("EquippedWeapon", weapon)

			Data.SetLocalPlayerData("Armor", currentInventory[armor])
			Data.SetLocalPlayerData("Helmet", currentInventory[helmet])
			Data.SetLocalPlayerData("Weapon", currentInventory[weapon])

			return {
				armor = armor,
				helmet = helmet,
				weapon = weapon,
			}
		end,
	}),

	inventory = Rodux.createReducer(nil, {
		UpdateInventory = function(_, action)
			return action.newInventory
		end,
	}),

	store = Rodux.createReducer({
		contents = {},
		open = false,
	}, {
		ToggleStore = function(store)
			local store = copy(store)
			store.open = not store.open
			return store
		end,

		UpdateCosmetics = function(store, action)
			local store = copy(store)
			store.contents = action.contents
			return store
		end,
	}),
}))

ReplicatedStorage.Remotes.UpdateCosmetics.OnClientEvent:connect(function(contents)
	Store:dispatch({
		type = "UpdateCosmetics",
		contents = contents,
	})
end)

ReplicatedStorage.Remotes.UpdateEquipment.OnClientEvent:connect(function(armor, helmet, weapon)
	Store:dispatch({
		type = "UpdateEquipment",
		newArmor = armor,
		newHelmet = helmet,
		newWeapon = weapon,
	})
end)

ReplicatedStorage.Remotes.UpdateInventory.OnClientEvent:connect(function(inventory)
	local loot = Loot.DeserializeTable(inventory)

	for _, item in pairs(loot) do
		if item.Type ~= "Helmet" and item.Type ~= "Armor" then
			for key, value in pairs(GunScaling.BaseStats(item.Type, item.Level, item.Rarity)) do
				if item[key] == nil then
					item[key] = value
				end
			end
		end
	end

	Store:dispatch({
		type = "UpdateInventory",
		newInventory = loot,
	})
end)

return Store
