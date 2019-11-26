local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local BossLaserTri = ReplicatedStorage.Assets.Campaign.Campaign3.Boss.BossLaserTri
local TriLaserEvent = ReplicatedStorage.Remotes.FirelandsBoss.TriLaser
local LocalPlayer = Players.LocalPlayer

local LASER_LOOK_DOWN = 0.3
local LASER_TIME = 3

if Dungeon.GetDungeonData("Campaign") ~= 3 then return end

local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()

local active = false

TriLaserEvent.OnClientEvent:connect(function(newActive)
	active = newActive
	if not active then return end

	local lasers = BossLaserTri:Clone()
	lasers.Parent = Workspace

	local time = 0

	local baseAngle = boss.PrimaryPart.CFrame - boss.PrimaryPart.Position

	local hurt = false

	local function hurtByLaser(part)
		if hurt then return end
		local character = LocalPlayer.Character
		if character and part:IsDescendantOf(character) then
			hurt = true
			TriLaserEvent:FireServer()
		end
	end

	for _, laser in pairs(lasers:GetChildren()) do
		laser.Touched:connect(hurtByLaser)
	end

	repeat
		boss:SetPrimaryPartCFrame(
			CFrame.new(boss.PrimaryPart.Position)
			* baseAngle
			* CFrame.Angles(
				(1 - TweenService:GetValue(
					time / LASER_LOOK_DOWN,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out
				)) - math.pi / 4,
				0,
				0
			)
		)

		time = time + RunService.Heartbeat:wait()
	until time >= LASER_LOOK_DOWN

	repeat
		boss:SetPrimaryPartCFrame(
			CFrame.new(boss.PrimaryPart.Position)
			* baseAngle
			* CFrame.Angles(
				TweenService:GetValue(
					time / (LASER_TIME - LASER_LOOK_DOWN),
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out
				) - math.pi / 4,
				0,
				0
			)
		)

		lasers:SetPrimaryPartCFrame(boss.Body.Eye.PrimaryPart.CFrame * CFrame.Angles(0, math.pi, 0))
		time = time + RunService.Heartbeat:wait()
	until not active

	lasers:Destroy()
end)
