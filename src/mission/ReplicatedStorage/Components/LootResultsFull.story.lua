local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateMockState = require(ReplicatedStorage.Libraries.CreateMockState)
local LootResults = require(script.Parent.LootResults)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

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
					Loot = {},
					GamemodeLoot = {},
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
