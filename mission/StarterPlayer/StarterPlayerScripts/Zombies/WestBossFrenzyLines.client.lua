local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)
local TouchHurt = require(ReplicatedStorage.Libraries.TouchHurt)

local BossLaserRing = ReplicatedStorage.Assets.Campaign.Campaign5.Boss.BossLaserRing
local ShootFrenzyLines = ReplicatedStorage.Remotes.WestBoss.ShootFrenzyLines
local ShootFrenzySpin = ReplicatedStorage.Remotes.WestBoss.ShootFrenzySpin

local COLOR_ACTIVE = Color3.new(1, 0, 0)
local DELAY = 1
local LIFETIME = 0.7
local ORIENTATION_DEFAULT = -180
local ORIENTATION_DELAY = 0.45
local SPIN_RANGE = 30
local SPIN_TIMES = 5

if Dungeon.GetDungeonData("Campaign") ~= 5 then return end

local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()

local function loopLines(ring, callback)
	for _, line in pairs(ring:GetChildren()) do
		if line.Name ~= "Root" then
			callback(line)
		end
	end
end

ShootFrenzyLines.OnClientEvent:connect(function()
	local touchHurt = TouchHurt.new(ShootFrenzyLines)

	local ring = BossLaserRing:Clone()
	ring:SetPrimaryPartCFrame(boss.PrimaryPart.CFrame)
	ring.Parent = Workspace

	loopLines(ring, function(line)
		line.Transparency = 1

		local index = tonumber(line.Name)

		RealDelay(index / 20, function()
			line.Transparency = 0
		end)
	end)

	wait(DELAY)

	loopLines(ring, function(line)
		local index = tonumber(line.Name)

		RealDelay(index / 20, function()
			touchHurt.AddPart(line)
			line.Color = COLOR_ACTIVE

			RealDelay(LIFETIME, function()
				line:Destroy()
			end)
		end)
	end)

	wait(LIFETIME + 2)

	ring:Destroy()
end)

ShootFrenzySpin.OnClientEvent:connect(function()
	for _ = 1, SPIN_TIMES do
		local touchHurt = TouchHurt.new(ShootFrenzySpin)

		boss:SetPrimaryPartCFrame(
			CFrame.new(boss.PrimaryPart.Position)
			* CFrame.Angles(0, math.rad(ORIENTATION_DEFAULT + math.random(-SPIN_RANGE, SPIN_RANGE)), 0)
		)

		local ring = BossLaserRing:Clone()
		ring:SetPrimaryPartCFrame(boss.PrimaryPart.CFrame)
		ring.Parent = Workspace

		wait(ORIENTATION_DELAY)

		loopLines(ring, function(line)
			line.Color = COLOR_ACTIVE
			touchHurt.AddPart(line)
		end)

		wait(LIFETIME)

		ring:Destroy()
	end

	-- boss.PrimaryPart.Orientation = Vector3.new(0, ORIENTATION_DEFAULT, 0)
end)
