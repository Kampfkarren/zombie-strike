local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assign = require(ReplicatedStorage.Core.assign)
local MockPlayer = require(ReplicatedStorage.Core.MockData.MockPlayer)
local Perks = require(ReplicatedStorage.Core.Perks)
local Rodux = require(ReplicatedStorage.Vendor.Rodux)

local mockPlayer = MockPlayer()

local CreateMockState = {}

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

function CreateMockState.Poor(page)
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
		}),

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
			current = page or "Inventory",
		}, {}),

		sprays = Rodux.createReducer({
			equipped = nil,
			owned = {},
		}, {}),

		store = Rodux.createReducer({
			contents = {},
			equipped = {},
			page = "Shop",
			xpExpiration = 0,
		}, {
			SetStorePage = function(state, action)
				local state = copy(state)
				state.page = action.page
				return state
			end,
		}),

		vouchers = Rodux.createReducer(0, {}),
	}))
end

function CreateMockState.Normal(page, other)
	local pet = {
		Type = "Pet",
		Rarity = 2,
		Model = 2,
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}

	local weapon = {}

	other = other or {}

	for key, value in pairs(mockPlayer.Weapon) do
		if key == "Perks" then
			value = {}
		end

		weapon[key] = value
	end

	table.insert(weapon.Perks, {
		Perk = Perks.Perks[1],
		Upgrades = 0,
	})

	table.insert(weapon.Perks, {
		Perk = Perks.Perks[2],
		Upgrades = 1,
	})

	table.insert(weapon.Perks, {
		Perk = Perks.Perks[3],
		Upgrades = 3,
	})

	return Rodux.Store.new(Rodux.combineReducers({
		brains = Rodux.createReducer(10000, {}),

		equipment = Rodux.createReducer({
			equippedArmor = mockPlayer.Armor,
			equippedHelmet = mockPlayer.Helmet,
			equippedWeapon = weapon,
			equippedPet = pet,
			equippedAttachment = {
				Type = "Laser",
				Rarity = 5,
				Model = 5,
				UUID = HttpService:GenerateGUID(false):gsub("-", ""),
			},

			armor = mockPlayer.Armor.UUID,
			helmet = mockPlayer.Helmet.UUID,
			weapon = weapon.UUID,
		}, {}),

		inventory = Rodux.createReducer({
			weapon,
			mockPlayer.Armor,
			mockPlayer.Helmet,
			pet,

			assign({
				Type = "Rifle",
				UUID = "1",
			}, mockPlayer.Weapon),

			assign({
				Model = 5,
				UUID = "2",
			}, mockPlayer.Armor),

			{
				Type = "Magazine",
				Rarity = 2,

				Favorited = false,

				Model = 2,
				UUID = "3",
			},

			assign({
				Level = 100,
				UUID = "4",
			}, mockPlayer.Helmet),
		}, {}),

		gold = Rodux.createReducer(6000, {}),

		goldShop = Rodux.createReducer({
			timestamp = os.time(),
			alreadyBought = { 1 },
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
			current = page or "Inventory",
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

			page = "Shop",
			xpExpiration = 0,
		}, {
			SetStorePage = function(state, action)
				local state = copy(state)
				state.page = action.page
				return state
			end,
		}),

		trading = Rodux.createReducer(other.trading or {
			trading = false,
		}, {}),

		vouchers = Rodux.createReducer(1, {}),
	}))
end

return CreateMockState
