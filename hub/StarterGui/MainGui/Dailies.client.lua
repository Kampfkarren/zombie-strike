local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DailiesDictionary = require(ReplicatedStorage.DailiesDictionary)

local Dailies = ReplicatedStorage.Remotes.Dailies
local LocalPlayer = Players.LocalPlayer

local DailyRewards = LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("MainGui")
	:WaitForChild("Main")
	:WaitForChild("DailyRewards")

Dailies.OnClientEvent:connect(function(streak)
	for day, reward in ipairs(DailiesDictionary) do
		local card = DailyRewards.Inner.Contents[day]
		card.Reward.RewardText.Text = reward .. "🧠"
		card.Reward.Strikethrough.Visible = day <= streak
	end

	DailyRewards.Visible = true
end)

DailyRewards.Inner.OK.MouseButton1Click:connect(function()
	DailyRewards.Visible = false
end)
