local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local Camera = Workspace.CurrentCamera
local Shake = ReplicatedStorage.RuddevEvents.Shake

local function playSound(soundFolder)
	local children = soundFolder:GetChildren()
	local sound = children[math.random(#children)]
	sound:Play()
end

if Dungeon.GetDungeonData("Campaign") == 1 then
	local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()

	boss:WaitForChild("Humanoid").AnimationPlayed:connect(function(track)
		if pcall(function() track:GetTimeOfKeyframe("summon") end) then
			track.KeyframeReached:connect(function()
				playSound(SoundService.ZombieSounds["1"].Boss.Summon)

				local direction = Camera.CFrame:VectorToObjectSpace(
					(Camera.CFrame.Position - boss.HumanoidRootPart.Position).Unit
				)

				for _ = 1, 5 do
					Shake:Fire(direction * 15)
					wait(0.1)
				end
			end)
		end
	end)
end
