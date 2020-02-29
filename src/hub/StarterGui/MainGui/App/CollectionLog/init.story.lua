local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CollectionLog = require(script.Parent)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Rodux = require(ReplicatedStorage.Vendor.Rodux)

local e = Roact.createElement

return function(target)
	local testStore = Rodux.Store.new(Rodux.createReducer({
		itemsCollected = {
			Pistol = { 1 },
			Magazine = { 2 },
			Helmet = { 3 },
			Armor = { 4 },
		},

		page = {
			current = "CollectionLog",
		},
	}, {}))

	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = testStore,
		}, {
			CollectionLog = e(CollectionLog),
		}), target, "CollectionLog"
	)

	return function()
		Roact.unmount(handle)
	end
end
