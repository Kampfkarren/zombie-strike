local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local PlaySound = require(ReplicatedStorage.Core.PlaySound)

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Ring = ReplicatedStorage.Assets.Campaign.Campaign4.Boss.Ring
local Shake = ReplicatedStorage.RuddevEvents.Shake
local Slam = ReplicatedStorage.Remotes.FrostlandsBoss.Slam
local SlamAnimation = ReplicatedStorage.Assets.Campaign.Campaign4.Boss.SlamAnimation

local RANGE = 500
local RING_DELAY = 0.75
local RINGS = 3
local SIZE_TWEEN = TweenInfo.new(
	6,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out
)

if Dungeon.GetDungeonData("Campaign") ~= 4 then return end

local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()

local animation = boss:WaitForChild("Humanoid"):LoadAnimation(SlamAnimation)

local function fireRing()
	local ring = Ring:Clone()
	ring.Position = boss.PrimaryPart.Position - Vector3.new(0, 6, 0)

	local touched = false

	ring.Touched:connect(function(part)
		if touched then return end
		if part:IsDescendantOf(LocalPlayer.Character) then
			touched = true
			Slam:FireServer()
		end
	end)

	ring.Parent = Workspace.Effects
	TweenService:Create(ring, SIZE_TWEEN, { Size = Vector3.new(RANGE, 0.25, RANGE) }):Play()
end

animation.KeyframeReached:connect(function()
	local direction = Camera.CFrame:VectorToObjectSpace(
		(Camera.CFrame.Position - boss.HumanoidRootPart.Position).Unit
	)

	Shake:Fire(direction * 15)
	PlaySound(SoundService.ZombieSounds["4"].Boss.Impact)

	for _ = 1, RINGS do
		fireRing()
		wait(RING_DELAY)
	end
end)

Slam.OnClientEvent:connect(function()
	animation:Play()
end)
