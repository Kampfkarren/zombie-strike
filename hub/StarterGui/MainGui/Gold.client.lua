local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local State = require(ReplicatedStorage.State)

local Gold = script.Parent.Main.Gold
local LocalPlayer = Players.LocalPlayer

local GoldValue = LocalPlayer
	:WaitForChild("PlayerData")
	:WaitForChild("Gold")

local function updateGold()
	Gold.GoldLabel.Text = GoldValue.Value .. " G"
	State:dispatch({
		type = "UpdateGold",
		gold = GoldValue.Value,
	})
end

updateGold()
GoldValue.Changed:connect(updateGold)
