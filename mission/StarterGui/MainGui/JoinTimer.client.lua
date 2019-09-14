local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local JoinTimerLabel = script.Parent.Main.JoinTimer

local joinTimerText = "%d/%d - %d"

ReplicatedStorage.JoinTimer.Changed:connect(function(timer)
	if timer > 0 then
		local amount = Dungeon.GetDungeonData("Members")
		local current = #Players:GetPlayers()

		JoinTimerLabel.Text = joinTimerText:format(current, amount, timer)
	end

	JoinTimerLabel.Visible = timer > 0
end)
