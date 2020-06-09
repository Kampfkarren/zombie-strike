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
				EquipmentLoot = {
					Type = "Grenade",
					Index = 2,
				},
			}),
		}), target, "ArenaRewards"
	)

	return function()
		Roact.unmount(handle)
	end
end
