local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BossTimer = script.Parent.Main.BossTimer

ReplicatedStorage.BossTimer.Changed:connect(function(timer)
	if timer > 0 then
		BossTimer.Text = timer
	else
		BossTimer.Text = ""
	end
end)
