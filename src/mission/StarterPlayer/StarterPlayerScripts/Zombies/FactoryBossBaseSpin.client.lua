local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BossSequenceFinished = ReplicatedStorage.LocalEvents.BossSequenceFinished
local LocalPlayer = Players.LocalPlayer
local HitByLaser = ReplicatedStorage.Remotes.FactoryBoss.HitByLaser

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local DAMAGE_COOLDOWN = 1
local SHIFT_MAX = 33
local SPIN_BUFF = 0.125
local SPIN_RATE = 0.34

if Dungeon.GetDungeonData("Campaign") ~= 2 then return end

BossSequenceFinished.Event:wait()

local boss = CollectionService:GetTagged("Boss")[1]
local humanoid = boss.Humanoid
local rod = boss.DrumSegment.Rod
local lasers = {
	{
		Laser = rod.Laser1,
		Origin = rod.Laser1.PrimaryPart.CFrame,
		Scale = -1,
	},

	{
		Laser = rod.Laser2,
		Origin = rod.Laser2.PrimaryPart.CFrame,
		Scale = 1,
	},
}

local total = 0

local rodBaseCFrame = rod.PrimaryPart.CFrame
local rng = Random.new()

local function shiftRods()
	for _, laser in pairs(lasers) do
		laser.Laser:SetPrimaryPartCFrame(laser.Origin
			+ Vector3.new(rng:NextNumber(0, SHIFT_MAX) * laser.Scale), 0, 0)
	end
end

shiftRods()

local angle = 0

local function getLevels()
	return math.floor(3 * (1 - humanoid.Health / humanoid.MaxHealth))
end

RunService.Heartbeat:connect(function(delta)
	local levels = getLevels()
	local rate = SPIN_RATE + (SPIN_BUFF * levels)
	angle = angle + delta * rate

	if angle >= math.pi * 2 then
		rod:SetPrimaryPartCFrame(rodBaseCFrame)
		angle = 0
		shiftRods()
	else
		rod:SetPrimaryPartCFrame(rod.PrimaryPart.CFrame * CFrame.Angles(0, 0, delta * rate))
	end
end)

local lastHitByLaser = 0

for _, laser in pairs(lasers) do
	laser.Laser.LaserWall.Touched:connect(function(part)
		if LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character) then
			if tick() - lastHitByLaser > DAMAGE_COOLDOWN then
				lastHitByLaser = tick()
				HitByLaser:FireServer()
			end
		end
	end)
end
