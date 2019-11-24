local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local Rodux = require(ReplicatedStorage.Vendor.Rodux)

local SetTreasureLoot = ReplicatedStorage.Remotes.SetTreasureLoot

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
		RefreshEquipment = function()
			return {
				equippedArmor = Data.GetLocalPlayerData("Armor"),
				equippedHelmet = Data.GetLocalPlayerData("Helmet"),
				equippedWeapon = Data.GetLocalPlayerData("Weapon"),
			}
		end,
	}),

	treasureLoot = Rodux.createReducer({
		bought = false,
		open = false,
	}, {
		SetTreasureLootOpen = function(state, action)
			local state = copy(state)
			state.open = action.open
			return state
		end,

		UpdateTreasureLoot = function(state, action)
			local state = copy(state)
			state.loot = action.loot
			return state
		end,

		TreasureBought = function(state)
			local state = copy(state)
			state.bought = true
			return state
		end,
	}),
}))

ReplicatedStorage.LocalEvents.AmbienceChanged.Event:connect(function(ambienceName)
	Store:dispatch({
		type = "SetTreasureLootOpen",
		open = ambienceName == "Treasure",
	})
end)

ReplicatedStorage.Remotes.TreasureBought.OnClientEvent:connect(function()
	Store:dispatch({
		type = "TreasureBought",
	})
end)

SetTreasureLoot.OnClientEvent:connect(function(serialized)
	local loot = Loot.Deserialize(serialized)

	Store:dispatch({
		type = "UpdateTreasureLoot",
		loot = loot,
	})
end)

return Store
