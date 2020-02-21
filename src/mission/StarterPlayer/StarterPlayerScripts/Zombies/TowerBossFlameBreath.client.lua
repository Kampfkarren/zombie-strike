local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local Maid = require(ReplicatedStorage.Core.Maid)
local PlayQuickSound = require(ReplicatedStorage.Core.PlayQuickSound)

local Assets = ReplicatedStorage.Assets.Campaign.Campaign6.Boss
local FlameBreath = ReplicatedStorage.Remotes.Tower.Boss.FlameBreath
local Flamethrower = SoundService.ZombieSounds["6"].Boss.Flamethrower
local LocalPlayer = Players.LocalPlayer

local ANGLE = CFrame.Angles(0, -math.pi / 2, -math.pi / 2)
local INVINCIBLE_FOR = 0.5
local WIND_UP_TIME = 0.83

local DURATIONS = {
	3,
	4,
	4.2,
	4.4,
	4.6,
}

local ROTATION_SPEEDS = {
	4,
	4.5,
	5.5,
	5.5,
	5.5,
}

if Dungeon.GetDungeonData("Campaign") ~= 6 then return end

local difficulty = Dungeon.GetDungeonData("Difficulty")
local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()

FlameBreath.OnClientEvent:connect(function()
	local maid = Maid.new()

	local startAnimation = boss.Humanoid:LoadAnimation(Assets.FireBreathStart)
	local loopAnimation = boss.Humanoid:LoadAnimation(Assets.FireBreathLoop)

	startAnimation:Play()

	local baseCFrame = boss:GetPrimaryPartCFrame()
	local cone = Assets.ConeRange:Clone()
	local size = cone.Size.Y / 2

	local origin = CFrame.new(boss.PrimaryPart.Position) * ANGLE + Vector3.new(0, 0, -size)
	cone.CFrame = origin
	cone.Color = Color3.new(1, 0.5, 0.5)

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = cone
	weld.Part1 = boss.PrimaryPart
	weld.Parent = cone

	cone.Parent = Workspace

	maid:GiveTask(cone)

	PlayQuickSound(Flamethrower.Start)

	wait(WIND_UP_TIME)

	local loop = Flamethrower.Loop:Clone()
	loop.Parent = cone
	loop:Play()
	maid:GiveTask(loop)

	local lastHit = 0
	cone.Touched:connect(function(part)
		if part:IsDescendantOf(LocalPlayer.Character) then
			if tick() - lastHit > INVINCIBLE_FOR then
				lastHit = tick()
				FlameBreath:FireServer()
			end
		end
	end)

	startAnimation:Stop()
	loopAnimation:Play()

	cone.Color = Color3.new(1, 0, 0)

	local speed = ROTATION_SPEEDS[difficulty]
	local total = 0

	maid:GiveTask(RunService.Heartbeat:connect(function(delta)
		total = total + delta

		if total >= DURATIONS[difficulty] then
			maid:DoCleaning()
			PlayQuickSound(Flamethrower.End)
			loopAnimation:Stop()
			boss:SetPrimaryPartCFrame(baseCFrame)
			return
		end

		boss:SetPrimaryPartCFrame(boss:GetPrimaryPartCFrame() * CFrame.Angles(0, delta * speed, 0))
	end))
end)
