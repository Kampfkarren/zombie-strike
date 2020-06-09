local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateMockState = require(ReplicatedStorage.Libraries.CreateMockState)
local GoldShop = require(script.Parent)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

return function(target)
	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = CreateMockState.Normal("GoldShop"),
		}, {
			GoldShop = e(GoldShop),
		}), target, "GoldShop"
	)

	return function()
		Roact.unmount(handle)
	end
end
