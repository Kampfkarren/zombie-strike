local ReplicatedStorage = game:GetService("ReplicatedStorage")

local App = require(ReplicatedStorage.Core.UI.Components.App)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local State = require(ReplicatedStorage.State)
local UseBetaFeature = require(ReplicatedStorage.Core.UseBetaFeature)

local BattlePass = require(script.BattlePass)
local Codes = require(script.Codes)
local CollectionLog = require(script.CollectionLog)
local Equipment = require(script.Equipment)
local Feedback = require(script.Feedback)
local Friends = require(script.Friends)
local GoldShop = require(script.GoldShop)
local Pets = require(script.Pets)
local Quests = require(script.Quests)
local Settings = require(script.Settings)
local Shopkeeper2 = require(script.Shopkeeper2)
local SoftShutdownAlert = require(script.SoftShutdownAlert)
local Store = require(script.Store)
local Trading = require(script.Trading)
local Vouchers = require(script.Vouchers)

local Inventory

if UseBetaFeature("Inventory2") then
	Inventory = require(script.Inventory2)
else
	Inventory = require(script.Inventory)
end

local e = Roact.createElement

local function Contents()
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	}, {
		BattlePass = e(BattlePass),
		Codes = e(Codes),
		CollectionLog = e(CollectionLog),
		Equipment = e(Equipment),
		Feedback = e(Feedback),
		Friends = e(Friends),
		GoldShop = e(GoldShop),
		Inventory = e(Inventory),
		Pets = e(Pets),
		Quests = e(Quests),
		Settings = e(Settings),
		Shopkeeper = e(Shopkeeper2),
		SoftShutdownAlert = e(SoftShutdownAlert),
		Store = e(Store),
		Trading = e(Trading),
		Vouchers = e(Vouchers, {
			redeem = require(script.Vouchers.RedeemVoucher),
		}),
	})
end

return e(RoactRodux.StoreProvider, {
	store = State,
}, {
	App = e(App.AppBase, {}, {
		Contents = e(Contents),
	}),
})
