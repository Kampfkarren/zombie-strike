local ReplicatedStorage = game:GetService("ReplicatedStorage")

local App = require(ReplicatedStorage.Core.UI.Components.App)
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
			Perks = { 1, 20, 23 },
		},

		page = {
			current = "CollectionLog",
		},
	}, {}))

	local handle = Roact.mount(
		e(RoactRodux.StoreProvider, {
			store = testStore,
		}, {
			e(App.AppBase, {}, {
				CollectionLog = e(CollectionLog, {
					initialPage = "Perks",
				}),
			}),
		}), target, "CollectionLog"
	)

	return function()
		Roact.unmount(handle)
	end
end
