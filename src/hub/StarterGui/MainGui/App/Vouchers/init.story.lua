local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateMockState = require(ReplicatedStorage.Libraries.CreateMockState)
local Perks = require(ReplicatedStorage.Core.Perks)
local Promise = require(ReplicatedStorage.Core.Promise)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Vouchers = require(script.Parent)

local e = Roact.createElement

local function mockRedeem()
	return Promise.resolve({
		Type = "Pistol",
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
		},

		Model = 5,
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	})
end

return function(target)
	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = CreateMockState.Normal("Vouchers"),
		}, {
			Vouchers = e(Vouchers, {
				redeem = mockRedeem,
			}),
		}), target, "Vouchers"
	)

	return function()
		Roact.unmount(handle)
	end
end
