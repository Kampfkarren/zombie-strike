local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Assets = ReplicatedStorage.Assets.Campaign.Campaign2.Boss
local HitByLaser = ReplicatedStorage.Remotes.FactoryBoss.HitByLaser
local Maid = require(ReplicatedStorage.Core.Maid)
local QuadLaser = ReplicatedStorage.Remotes.FactoryBoss.QuadLaser

local DAMAGE_BUFF = 1.125
local FINALE_CRUMBLE = 1.4
local FINALE_TIME = 3
local HEALTH_COLOR_BLINK_HEALTH = 0.1
local HEALTH_COLOR_BLINK_RATE = 0.2
local QUAD_LASER_TIME = 3
local TUBES = 4

local BLACK = Color3.new()
local RED = Color3.fromRGB(231, 76, 60)

PhysicsService:CreateCollisionGroup("FactoryBoss")
PhysicsService:CollisionGroupSetCollidable("FactoryBoss", "FactoryBoss", false)

local FactoryBoss = {}
FactoryBoss.__index = FactoryBoss

FactoryBoss.LaserDamageScale = {
	[30] = 2200,
	[36] = 7200,
	[42] = 19800,
	[48] = 60000,
	[54] = 168000,
}

FactoryBoss.QuadLaserChargeTime = 2.5

FactoryBoss.QuadLaserDamageScale = {
	[30] = 2000,
	[36] = 6000,
	[42] = 16500,
	[48] = 50000,
	[54] = 140000,
}

FactoryBoss.QuadLaserRateOfFireScale = {
	[30] = 8.0,
	[36] = 7.5,
	[42] = 7.0,
	[48] = 6.5,
	[54] = 6.0,
}

FactoryBoss.QuadLaserTime = {
	[30] = 1.5,
	[36] = 1.6,
	[42] = 1.7,
	[48] = 1.8,
	[54] = 1.9,
}

FactoryBoss.Name = "The Evil Dr. Zombie"

local function getLevels(humanoid)
	return math.floor(3 * (1 - humanoid.Health / humanoid.MaxHealth))
end

function FactoryBoss.new()
	return setmetatable({
		blinking = false,
		healthColors = {
			{ 1 / 3, RED },
			{ 2 / 3, Color3.fromRGB(241, 196, 15) },
		},
	}, FactoryBoss)
end

function FactoryBoss.GetModel()
	return assert(Workspace:FindFirstChild("The Evil Dr. Zombie", true))
end

function FactoryBoss:InitializeBossAI()
	CollectionService:AddTag(self.instance, "Zombie")

	self.instance.Humanoid.HealthChanged:connect(function(health)
		local nextHealth = self.healthColors[#self.healthColors]
		local ratio = (health / self.instance.Humanoid.MaxHealth)

		if nextHealth ~= nil then
			if ratio <= nextHealth[1] then
				self:SetWarningColor(nextHealth[2])
				table.remove(self.healthColors)

				local nextEmit = math.random(10, 20) / 100
				local total = 0

				self.maid:GiveTask(RunService.Heartbeat:connect(function(delta)
					total = total + delta
					if total >= nextEmit then
						self:EmitFire()
						nextEmit = math.random(10, 20) / 100
						total = 0
					end
				end))
			end
		elseif ratio <= HEALTH_COLOR_BLINK_HEALTH and not self.blinking then
			self.blinking = true

			local color = RED
			local last = 0

			self.aliveMaid:GiveTask(RunService.Heartbeat:connect(function(delta)
				last = last + delta
				if last >= HEALTH_COLOR_BLINK_RATE then
					last = 0

					local newColor = color == RED and BLACK or RED

					self:SetWarningColor(newColor)
					color = newColor
				end
			end))
		end
	end)

	HitByLaser.OnServerEvent:connect(function(player)
		local character = player.Character
		if character then
			local damage = FactoryBoss.LaserDamageScale[self.level]
			if not damage then
				error("FactoryBoss.HitByLaser: no damage scale for " .. self.level)
			end
			character:WaitForChild("Humanoid"):TakeDamage(damage * DAMAGE_BUFF ^ getLevels(self.instance.Humanoid))
		end
	end)

	QuadLaser.OnServerEvent:connect(function(player)
		local character = player.Character
		if character then
			local damage = FactoryBoss.QuadLaserDamageScale[self.level]
			if not damage then
				error("FactoryBoss.QuadLaser: no damage scale for " .. self.level)
			end
			character:WaitForChild("Humanoid"):TakeDamage(damage * DAMAGE_BUFF ^ getLevels(self.instance.Humanoid))
		end
	end)

	wait(math.random(1, 3))

	while true do
		wait(FactoryBoss.QuadLaserRateOfFireScale[self.level])
		if self.alive then
			self:QuadLaser()
		else
			break
		end
	end
end

function FactoryBoss:SetWarningColor(color)
	for _, part in pairs(self.instance.HealthSegment:GetChildren()) do
		if part.Name == "Warning" then
			part.Color = color
		end
	end
end

function FactoryBoss:Spawn()
	self:AfterSpawn()
	self:SetupHumanoid()
	return self.instance
end

function FactoryBoss:QuadLaser()
	local maid = Maid.new()
	self.aliveMaid:GiveTask(maid)

	local laserTubes = self.instance.BaseSegment.LaserTubes

	for tubeIndex = 1, TUBES do
		local tube = laserTubes["LaserTube" .. tubeIndex]

		local chargeEffect = Assets.ChargeEffect:Clone()
		chargeEffect.Parent = tube.ShooterAttachment
		maid:GiveTask(chargeEffect)
	end

	QuadLaser:FireAllClients(FactoryBoss.QuadLaserTime[self.level])
	wait(FactoryBoss.QuadLaserTime[self.level] + QUAD_LASER_TIME)
	maid:DoCleaning()
end

function FactoryBoss:AfterDeath()
	local breaking = false
	local count = 0
	local total = 0

	while total < FINALE_TIME do
		total = total + RunService.Heartbeat:wait()
		count = count + 1
		if count % 3 == 0 then
			self:EmitFire()
		end

		if not breaking and total >= FINALE_CRUMBLE then
			for _, thing in pairs(self.instance:GetDescendants()) do
				if thing:IsA("BasePart") then
					PhysicsService:SetPartCollisionGroup(thing, "FactoryBoss")
					thing.Anchored = false
					thing.Velocity = Vector3.new(
						math.random(-10, 10),
						math.random(-10, 10),
						math.random(-10, 10)
					)
				end
			end
		end
	end
end

function FactoryBoss:EmitFire()
	local particles = CollectionService:GetTagged("FinaleExplode")
	particles[math.random(#particles)]:Emit(math.random(2, 4))
end

function FactoryBoss.UpdateNametag() end

return FactoryBoss
