local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateMockState = require(ReplicatedStorage.Libraries.CreateMockState)
local Equipped = require(script.Parent.Equipped)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

return function(target)
	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = CreateMockState.Normal(),
		}, {
			Equipped = e(Equipped, {
				SetPage = function() end,
			}),
		}), target, "Equipped"
	)

	return function()
		Roact.unmount(handle)
	end
end
