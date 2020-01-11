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
			local equipment = {
				equippedArmor = Data.GetLocalPlayerData("Armor"),
				equippedHelmet = Data.GetLocalPlayerData("Helmet"),
				equippedWeapon = Data.GetLocalPlayerData("Weapon"),
			}

			if ReplicatedStorage.HubWorld.Value then
				equipment.equippedAttachment = Data.GetLocalPlayerData("Attachment")
			end

			return equipment
		end,
	}),

	sprays = Rodux.createReducer({}, {
		SetEquippedSpray = function(_, action)
			return {
				equipped = action.equipped,
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

		TreasureBought = function(state, action)
			local state = copy(state)
			state.bought = true
			state.donor = action.donor
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

ReplicatedStorage.Remotes.UseSpray.OnClientEvent:connect(function(equipped)
	Store:dispatch({
		type = "SetEquippedSpray",
		equipped = equipped,
	})
end)

ReplicatedStorage.Remotes.TreasureBought.OnClientEvent:connect(function(donor)
	Store:dispatch({
		type = "TreasureBought",
		donor = donor,
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
