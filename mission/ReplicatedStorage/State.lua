local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local Rodux = require(ReplicatedStorage.Vendor.Rodux)

local Store

Store = Rodux.Store.new(Rodux.combineReducers({
	equipment = Rodux.createReducer(nil, {
		RefreshEquipment = function()
			return {
				equippedArmor = Data.GetLocalPlayerData("Armor"),
				equippedHelmet = Data.GetLocalPlayerData("Helmet"),
				equippedWeapon = Data.GetLocalPlayerData("Weapon"),
			}
		end,
	}),
}))

return Store
