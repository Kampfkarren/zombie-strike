local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MockPlayer = require(ReplicatedStorage.Core.MockData.MockPlayer)
local Rodux = require(ReplicatedStorage.Vendor.Rodux)

local mockPlayer = MockPlayer()

local CreateMockState = {}

function CreateMockState.Poor()
	return Rodux.Store.new(Rodux.combineReducers({
		equipment = Rodux.createReducer({
			equippedArmor = mockPlayer.Armor,
			equippedHelmet = mockPlayer.Helmet,
			equippedWeapon = mockPlayer.Weapon,
		}, {}),

		inventory = Rodux.createReducer({
			mockPlayer.Weapon,
			mockPlayer.Armor,
			mockPlayer.Helmet,
		}, {}),

		hideUi = Rodux.createReducer(0, {
			HideUI = function()
				return 0
			end,
		}, {}),

		nametags = Rodux.createReducer({
			fonts = {
				equipped = nil,
				owned = {},
			},

			titles = {
				equipped = nil,
				owned = {},
			},
		}, {}),

		page = Rodux.createReducer({
			current = "Inventory"
		}, {}),

		sprays = Rodux.createReducer({
			equipped = nil,
			owned = {},
		}, {}),

		store = Rodux.createReducer({
			contents = {},
			equipped = {},
		}, {}),
	}))
end

function CreateMockState.Normal()
	local pet = {
		Type = "Pet",
		Rarity = 2,
		Model = 2,
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}

	return Rodux.Store.new(Rodux.combineReducers({
		equipment = Rodux.createReducer({
			equippedArmor = mockPlayer.Armor,
			equippedHelmet = mockPlayer.Helmet,
			equippedWeapon = mockPlayer.Weapon,
			equippedPet = pet,
			equippedAttachment = {
				Type = "Laser",
				Rarity = 5,
				Model = 5,
				UUID = HttpService:GenerateGUID(false):gsub("-", ""),
			},
		}, {}),

		inventory = Rodux.createReducer({
			mockPlayer.Weapon,
			mockPlayer.Armor,
			mockPlayer.Helmet,
			pet,
		}, {}),

		hideUi = Rodux.createReducer(0, {
			HideUI = function()
				return 0
			end,
		}, {}),

		nametags = Rodux.createReducer({
			fonts = {
				equipped = 1,
				owned = { 1, 2 },
			},

			titles = {
				equipped = 1,
				owned = { 1, 2, 3 },
			},
		}, {}),

		page = Rodux.createReducer({
			current = "Inventory"
		}, {}),

		sprays = Rodux.createReducer({
			equipped = 1,
			owned = { 1, 2, 3 },
		}, {}),

		store = Rodux.createReducer({
			contents = { 1, 3, 4, 6, 7, 194, 195, 8 },

			equipped = {
				Helmet = 3,
				Armor = 4,
				GunSkin = 194,
				Particle = 8,
			},
		}, {}),
	}))
end

return CreateMockState
