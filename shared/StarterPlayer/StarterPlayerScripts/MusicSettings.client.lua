local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Settings = require(ReplicatedStorage.Core.Settings)

Settings.HookSetting("Music", function(volume)
	SoundService.Music.Volume = volume
end)
