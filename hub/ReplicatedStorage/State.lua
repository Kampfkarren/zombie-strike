local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local Rodux = require(ReplicatedStorage.Vendor.Rodux)

local Store

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
}))

ReplicatedStorage.Remotes.UpdateEquipment.OnClientEvent:connect(function(armor, helmet, weapon)
	Store:dispatch({
		type = "UpdateEquipment",
		newArmor = armor,
		newHelmet = helmet,
		newWeapon = weapon,
	})
end)

ReplicatedStorage.Remotes.UpdateInventory.OnClientEvent:connect(function(inventory)
	Store:dispatch({
		type = "UpdateInventory",
		newInventory = Loot.DeserializeTable(inventory),
	})
end)

return Store
