local ReplicatedStorage = game:GetService("ReplicatedStorage")

local App = require(ReplicatedStorage.Core.UI.Components.App)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local State = require(ReplicatedStorage.State)

local Arena = require(script.Arena)
local Lives = require(script.Lives)
local TreasureLoot = require(script.TreasureLoot)
local TreasureNotification = require(script.TreasureNotification)

local e = Roact.createElement

local function Contents()
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	}, {
		Arena = e(Arena),
		Lives = e(Lives),
		TreasureLoot = e(TreasureLoot),
		TreasureNotification = e(TreasureNotification),
	})
end

return e(RoactRodux.StoreProvider, {
	store = State,
}, {
	App = e(App.AppBase, {}, {
		Contents = e(Contents),
	}),
})
