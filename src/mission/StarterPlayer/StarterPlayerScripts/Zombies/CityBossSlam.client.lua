local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local Assets = ReplicatedStorage.Assets.Campaign.Campaign1.Boss

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local HitBySlam = ReplicatedStorage.Remotes.CityBoss.HitBySlam
local Ring = Assets.Ring
local Shake = ReplicatedStorage.RuddevEvents.Shake
local SlamAnimation = Assets.SlamAnimation

-- face palm...
local COUNT = { 2, 3, 4, 5, 6 }
local INTERVAL = { 1.5, 1.3, 1.1, 0.9, 0.6 }
local RANGE = 500

local sizeTween = TweenInfo.new(
	6,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out
)

local function playSound(soundFolder)
	local children = soundFolder:GetChildren()
	local sound = children[math.random(#children)]
	sound:Play()
end

if Dungeon.GetDungeonData("Campaign") == 1 then
	local difficulty = Dungeon.GetDungeonData("Difficulty")

	local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()

	local RingSpawn = Workspace:FindFirstChild("RingSpawn", true)

	local function slam()
		local direction = Camera.CFrame:VectorToObjectSpace(
			(Camera.CFrame.Position - boss.HumanoidRootPart.Position).Unit
		)

		playSound(SoundService.ZombieSounds["1"].Boss.Impact)
		Shake:Fire(direction * 15)

		local ring = Ring:Clone()
		ring.Position = RingSpawn.WorldPosition

		local touched = false

		ring.Touched:connect(function(part)
			if touched then return end
			if part:IsDescendantOf(LocalPlayer.Character) then
				touched = true
				HitBySlam:FireServer()
			end
		end)

		ring.Parent = Workspace.Effects
		TweenService:Create(ring, sizeTween, { Size = Vector3.new(RANGE, 0.25, RANGE) }):Play()
	end

	HitBySlam.OnClientEvent:connect(function()
		for _ = 1, COUNT[difficulty] do
			local slamAnimation = boss.Humanoid:LoadAnimation(SlamAnimation)
			slamAnimation:AdjustSpeed(1 / INTERVAL[difficulty])
			slamAnimation.KeyframeReached:connect(slam)
			slamAnimation:Play()

			wait(INTERVAL[difficulty])
		end
	end)
end
