local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MockPlayer = require(ReplicatedStorage.Core.MockData.MockPlayer)
local Perks = require(ReplicatedStorage.Core.Perks)
local Rodux = require(ReplicatedStorage.Vendor.Rodux)

local mockPlayer = MockPlayer()

local CreateMockState = {}

function CreateMockState.Normal()
	return Rodux.Store.new(Rodux.combineReducers({
		equipment = Rodux.createReducer({
			equippedArmor = mockPlayer.Armor,
			equippedHelmet = mockPlayer.Helmet,
			equippedWeapon = mockPlayer.Weapon,
		}, {}),

		treasureLoot = Rodux.createReducer({
			bought = false,
			loot = {
				Type = "Rifle",
				Level = 1,
				Rarity = 5,

				Bonus = 0,
				Favorited = false,
				Seed = 0,

				Perks = { { 1, 0 }, { 2, 0 }, { 3, 0 }, { 4, 0 } },

				Model = 5,
				UUID = HttpService:GenerateGUID(false):gsub("-", ""),
			},
			open = true,
		}, {}),
	}))
end

return CreateMockState
