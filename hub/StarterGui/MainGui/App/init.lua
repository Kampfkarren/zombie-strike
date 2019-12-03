local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local State = require(ReplicatedStorage.State)

local Codes = require(script.Codes)
local Feedback = require(script.Feedback)
local Inventory = require(script.Inventory)
local Quests = require(script.Quests)
local Settings = require(script.Settings)
local Shopkeeper = require(script.Shopkeeper)
local SoftShutdownAlert = require(script.SoftShutdownAlert)
local Store = require(script.Store)
local Trading = require(script.Trading)

local e = Roact.createElement

local function App()
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	}, {
		Codes = e(Codes),
		Feedback = e(Feedback),
		Inventory = e(Inventory),
		Quests = e(Quests),
		Settings = e(Settings),
		Shopkeeper = e(Shopkeeper),
		SoftShutdownAlert = e(SoftShutdownAlert),
		Store = e(Store),
		Trading = e(Trading),
	})
end

return e(RoactRodux.StoreProvider, {
	store = State,
}, {
	App = e(App),
})
