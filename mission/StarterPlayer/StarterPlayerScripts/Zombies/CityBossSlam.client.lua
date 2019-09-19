local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local HitBySlam = ReplicatedStorage.Remotes.CityBoss.HitBySlam
local Ring = ReplicatedStorage.Assets.Campaign.Campaign1.Boss.Ring
local Shake = ReplicatedStorage.RuddevEvents.Shake

local RANGE = 500

local sizeTween = TweenInfo.new(
	6,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out
)

if Dungeon.GetDungeonData("Campaign") == 1 then
	local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()

	local RingSpawn = Workspace:FindFirstChild("RingSpawn", true)

	boss:WaitForChild("Humanoid").AnimationPlayed:connect(function(track)
		if pcall(function() track:GetTimeOfKeyframe("Slam") end) then
			track.KeyframeReached:connect(function()
				local direction = Camera.CFrame:VectorToObjectSpace(
					(Camera.CFrame.Position - boss.HumanoidRootPart.Position).Unit
				)

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
			end)
		end
	end)
end