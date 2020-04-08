local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local GetStats = require(ReplicatedStorage.Libraries.GetStats)
local PlaySound = require(ReplicatedStorage.Core.PlaySound)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local Assets = ReplicatedStorage.Assets.Campaign.Campaign2.Boss
local LocalPlayer = Players.LocalPlayer
local QuadLaser = ReplicatedStorage.Remotes.FactoryBoss.QuadLaser

local OSCILLATE_SIZE = 0.2
local OSCILLATE_TIME = 0.1

local ROTATE_RATE = 0.25

local TUBES = 8

if Dungeon.GetDungeonData("Campaign") ~= 2 then return end

local function resetLaser(laser, base)
	laser.CFrame = base.CFrame + (base.CFrame.RightVector * laser.Size.X / 2)
end

local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()

local laserTubes = boss:WaitForChild("BaseSegment"):WaitForChild("LaserTubes")
local stats = GetStats().Boss

QuadLaser.OnClientEvent:connect(function()
	for tubeIndex = 1, TUBES do
		local base = laserTubes["LaserTube" .. tubeIndex]
		local laser = Assets.QuadLaser:Clone()
		local shooting = false

		resetLaser(laser, base)

		local baseLaserSize = laser.Size
		local total = 0

		local laserConnection = RunService.Heartbeat:connect(function(time)
			if shooting then
				total = total + time
				laser.Size = baseLaserSize
					+ (baseLaserSize * Vector3.new(
						0,
						math.sin(total / OSCILLATE_TIME) * OSCILLATE_SIZE,
						math.sin(total / OSCILLATE_TIME) * OSCILLATE_SIZE
					))
			end

			resetLaser(laser, base)
		end)

		local hurt = false

		laser.Touched:connect(function(part)
			if not hurt
				and shooting
				and LocalPlayer.Character
				and part:IsDescendantOf(LocalPlayer.Character)
			then
				hurt = true
				QuadLaser:FireServer()
			end
		end)

		laser.Parent = Workspace

		RealDelay(stats.QuadLaserChargeTime, function()
			shooting = true
			laser.Color = Color3.new(1, 0, 0)
			PlaySound(SoundService.SFX.Laser.Big)
			RealDelay(stats.QuadLaserTime, function()
				laserConnection:disconnect()
				laser:Destroy()
			end)
		end)
	end
end)

RunService.Heartbeat:connect(function(delta)
	laserTubes:SetPrimaryPartCFrame(
		laserTubes.PrimaryPart.CFrame * CFrame.Angles(0, delta * ROTATE_RATE, 0)
	)
end)
