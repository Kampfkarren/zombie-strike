local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local Assets = ReplicatedStorage.Assets.Campaign.Campaign2.Boss
local LocalPlayer = Players.LocalPlayer
local QuadLaser = ReplicatedStorage.Remotes.FactoryBoss.QuadLaser

local OSCILLATE_SIZE = 0.2
local OSCILLATE_TIME = 0.1

local QUAD_LASER_TIME = 3
local ROTATE_RATE = 0.15

local TUBES = 4

if Dungeon.GetDungeonData("Campaign") ~= 2 then return end

local function resetLaser(laser, base)
	laser.CFrame = base.CFrame + (base.CFrame.RightVector * laser.Size.X / 2)
end

local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()

local laserTubes = boss:WaitForChild("BaseSegment"):WaitForChild("LaserTubes")

QuadLaser.OnClientEvent:connect(function(activeTimer)
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
			if shooting and LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character) then
				hurt = true
				QuadLaser:FireServer()
			end
		end)

		laser.Parent = Workspace

		delay(QUAD_LASER_TIME, function()
			shooting = true
			laser.Color = Color3.new(1, 0, 0)
			delay(activeTimer, function()
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
