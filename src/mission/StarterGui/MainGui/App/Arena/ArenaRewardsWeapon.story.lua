local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArenaRewards = require(script.Parent.ArenaRewards)
local CreateMockState = require(ReplicatedStorage.Libraries.CreateMockState)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

return function(target)
	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = CreateMockState.Normal(),
		}, {
			ArenaRewards = e(ArenaRewards, {
				ItemLoot = {
					Type = "Pistol",
					Level = math.random(1, 100),
					Rarity = math.random(1, 5),

					Bonus = 0,
					Favorited = false,
					Seed = 0,

					Perks = {},

					Model = math.random(1, 5),
					UUID = HttpService:GenerateGUID(false):gsub("-", ""),
				},
			}),
		}), target, "ArenaRewards"
	)

	return function()
		Roact.unmount(handle)
	end
end
