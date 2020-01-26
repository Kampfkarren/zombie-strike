local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local Music = SoundService.Music[Dungeon.GetDungeonData("Campaign")]

local fadedMain = false

ReplicatedStorage.BossTimer.Changed:connect(function(timer)
	if fadedMain then return end

	if timer > 0 then
		fadedMain = true
		TweenService:Create(
			Music.Main,
			TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{ Volume = 0 }
		):Play()
	end
end)

ReplicatedStorage.JoinTimer.Changed:connect(function(timer)
	if timer == -4 then
		Music.Main:Play()
	end
end)

CollectionService:GetInstanceAddedSignal("Boss"):connect(function(boss)
	if not Music.Boss.Playing then
		Music.Boss:Play()
	end

	boss:WaitForChild("Humanoid").Died:connect(function()
		TweenService:Create(
			Music.Main,
			TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{ Volume = 0 }
		):Play()
	end)
end)

ReplicatedStorage:WaitForChild("PlayMissionMusic", math.huge)
Music.Main:Play()
