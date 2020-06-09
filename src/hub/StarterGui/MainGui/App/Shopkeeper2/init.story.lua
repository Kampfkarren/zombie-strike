local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateMockState = require(ReplicatedStorage.Libraries.CreateMockState)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Shopkeeper2 = require(script.Parent)

local e = Roact.createElement

return function(target)
	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = CreateMockState.Normal("Shopkeeper"),
		}, {
			Shopkeeper2 = e(Shopkeeper2),
		}), target, "Shopkeeper2"
	)

	return function()
		Roact.unmount(handle)
	end
end
