local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local State = require(ReplicatedStorage.State)

local Brains = script.Parent.Main.Brains
local Gold = script.Parent.Main.Gold
local LocalPlayer = Players.LocalPlayer

local BrainsValue = LocalPlayer
	:WaitForChild("PlayerData")
	:WaitForChild("Brains")

local GoldValue = LocalPlayer
	:WaitForChild("PlayerData")
	:WaitForChild("Gold")

local function updateGold()
	Gold.GoldLabel.Text = GoldValue.Value

	State:dispatch({
		type = "UpdateGold",
		gold = GoldValue.Value,
	})
end

updateGold()
GoldValue.Changed:connect(updateGold)

local function updateBrains()
	Brains.BrainsLabel.Text = BrainsValue.Value .. " 🧠"

	State:dispatch({
		type = "UpdateBrains",
		brains = BrainsValue.Value,
	})
end

Brains.BuyButton.MouseButton1Click:connect(function()
	State:dispatch({
		type = "OpenStore",
	})

	State:dispatch({
		type = "SetStorePage",
		page = "BuyBrains",
	})
end)

Gold.BuyButton.MouseButton1Click:connect(function()
	State:dispatch({
		type = "OpenStore",
	})

	State:dispatch({
		type = "SetStorePage",
		page = "BuyCaps",
	})
end)

updateBrains()
BrainsValue.Changed:connect(updateBrains)
