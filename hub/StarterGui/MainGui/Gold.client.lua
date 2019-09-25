local Players = game:GetService("Players")

local Gold = script.Parent.Main.Gold
local LocalPlayer = Players.LocalPlayer

local GoldValue = LocalPlayer
	:WaitForChild("PlayerData")
	:WaitForChild("Gold")

local function updateGold()
	Gold.GoldLabel.Text = GoldValue.Value .. " G"
end

updateGold()
GoldValue.Changed:connect(updateGold)
