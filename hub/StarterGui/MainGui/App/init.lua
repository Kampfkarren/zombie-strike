local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local State = require(ReplicatedStorage.State)

local Feedback = require(script.Feedback)
local Inventory = require(script.Inventory)
local Settings = require(script.Settings)
local Shopkeeper = require(script.Shopkeeper)
local Store = require(script.Store)

local e = Roact.createElement

local function App()
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	}, {
		Feedback = e(Feedback),
		Inventory = e(Inventory),
		Settings = e(Settings),
		Shopkeeper = e(Shopkeeper),
		Store = e(Store),
	})
end

return e(RoactRodux.StoreProvider, {
	store = State,
}, {
	App = e(App),
})
