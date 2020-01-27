local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local GetCodeName = require(ReplicatedStorage.Libraries.GetCodeName)

local Music = SoundService.Music[GetCodeName()]

local fadedMain = false
local isBossMode = Dungeon.GetDungeonData("Gamemode") == "Boss"

local function fadeMusic(music)
	TweenService:Create(
		music,
		TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{ Volume = 0 }
	):Play()
end

ReplicatedStorage.BossTimer.Changed:connect(function(timer)
	if fadedMain then return end

	if timer > 0 then
		fadedMain = true
		fadeMusic(Music.Main)
	end
end)

ReplicatedStorage.JoinTimer.Changed:connect(function(timer)
	if timer == -4 and not isBossMode then
		Music.Main:Play()
	end
end)

CollectionService:GetInstanceAddedSignal("Boss"):connect(function(boss)
	local playingMusic = isBossMode and Music.Phase0 or Music.Boss

	if not playingMusic.Playing then
		playingMusic:Play()
	end

	boss:WaitForChild("Humanoid").Died:connect(function()
		fadeMusic(playingMusic)
	end)

	if isBossMode then
		Music.Phase0:Play()

		local phase = boss:WaitForChild("CurrentPhase")
		phase.Changed:connect(function(newPhase)
			local music = Music["Phase" .. newPhase]
			if not music.Playing then
				fadeMusic(playingMusic)
				playingMusic = music
				music:Play()
			end
		end)
	end
end)

ReplicatedStorage:WaitForChild("PlayMissionMusic", math.huge)
if not isBossMode then
	Music.Main:Play()
end
