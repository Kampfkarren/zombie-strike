local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CollectionLogContents = require(script.Parent.CollectionLogContents)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Rodux = require(ReplicatedStorage.Vendor.Rodux)

local e = Roact.createElement

return function(target)
	local testStore = Rodux.Store.new(Rodux.createReducer({
		itemsCollected = {
			Pistol = { 2 },
			Magazine = { 2 },
			Helmet = { 3 },
			Armor = { 4 },
		},
	}, {}))

	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = testStore,
		}, {
			CollectionLogContents = e(CollectionLogContents),
		}), target, "CollectionLogContents"
	)

	return function()
		Roact.unmount(handle)
	end
end
