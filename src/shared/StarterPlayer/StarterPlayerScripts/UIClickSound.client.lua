local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Collection = require(ReplicatedStorage.Core.Collection)

Collection("UIClick", function(button)
	button.Activated:connect(function()
		SoundService.SFX.Click:Play()
	end)
end)
