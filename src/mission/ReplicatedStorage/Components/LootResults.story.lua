local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateMockState = require(ReplicatedStorage.Libraries.CreateMockState)
local LootResults = require(script.Parent.LootResults)
local Perks = require(ReplicatedStorage.Core.Perks)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

local ARMOR = {
	Type = "Armor",
	Level = 1,
	Rarity = 1,

	Upgrades = 0,
	Favorited = false,

	Model = 1,
	UUID = HttpService:GenerateGUID(false):gsub("-", ""),
}

local ATTACHMENT = {
	Type = "Silencer",
	Rarity = 1,

	Favorited = false,

	Model = 1,
	UUID = HttpService:GenerateGUID(false):gsub("-", ""),
}

local HELMET = {
	Type = "Helmet",
	Level = 1,
	Rarity = 1,

	Upgrades = 0,
	Favorited = false,

	Model = 1,
	UUID = HttpService:GenerateGUID(false):gsub("-", ""),
}

local WEAPON = {
	Type = "Rifle",
	Level = 1,
	Rarity = 5,

	Bonus = 0,
	Favorited = false,
	Seed = 0,

	Perks = {
		{
			Perk = Perks.Perks[1],
			Upgrades = 0,
		},

		{
			Perk = Perks.Perks[2],
			Upgrades = 0,
		},

		{
			Perk = Perks.Perks[3],
			Upgrades = 0,
		},

		{
			Perk = Perks.Perks[4],
			Upgrades = 0,
		},
	},

	Model = 5,
	UUID = HttpService:GenerateGUID(false):gsub("-", ""),
}

return function(target)
	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = CreateMockState.Normal(),
		}, {
			e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				LootResults = e(LootResults, {
					AnimateXPNow = true,
					Loot = { WEAPON, ARMOR, HELMET, ATTACHMENT },
					GamemodeLoot = {{
						Type = "Brains",
						Brains = 100,
					}},
					Caps = 500,
					XP = 5000000,
				}),
			}),
		 }), target, "LootResults"
	)

	return function()
		Roact.unmount(handle)
	end
end
