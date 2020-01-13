local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local State = require(ReplicatedStorage.State)

local BattlePass = require(script.BattlePass)
local Codes = require(script.Codes)
local Equipment = require(script.Equipment)
local Feedback = require(script.Feedback)
local Friends = require(script.Friends)
local Inventory = require(script.Inventory)
local Pets = require(script.Pets)
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
		BattlePass = e(BattlePass),
		Codes = e(Codes),
		Equipment = e(Equipment),
		Feedback = e(Feedback),
		Friends = e(Friends),
		Inventory = e(Inventory),
		Pets = e(Pets),
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
