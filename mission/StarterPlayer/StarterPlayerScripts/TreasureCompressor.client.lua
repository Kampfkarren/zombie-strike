local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

ReplicatedStorage.LocalEvents.AmbienceChanged.Event:connect(function(ambienceName)
	SoundService.Music.TreasureCompressor.Enabled = ambienceName == "Treasure"
end)
