local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateMockState = require(ReplicatedStorage.Libraries.CreateMockState)
local Nametag = require(script.Parent.Nametag)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

return function(target)
	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = CreateMockState.Normal(),
		}, {
			Frame = e("Frame", {
				BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.fromScale(1, 1),
			}, {
				Nametag = e(Nametag),
			}),
		}), target, "Nametag"
	)

	return function()
		Roact.unmount(handle)
	end
end
