local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateMockState = require(ReplicatedStorage.Libraries.CreateMockState)
local Promise = require(ReplicatedStorage.Core.Promise)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Vouchers = require(script.Parent)

local e = Roact.createElement

return function(target)
	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = CreateMockState.Normal("Vouchers"),
		}, {
			Vouchers = e(Vouchers, {
				redeem = function()
					return Promise.new(function() end)
				end,
			}),
		}), target, "Vouchers"
	)

	return function()
		Roact.unmount(handle)
	end
end
