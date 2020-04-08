local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Assets = ReplicatedStorage.Assets.Campaign.Campaign2.Boss
local FloorLaser = ReplicatedStorage.Remotes.FactoryBoss.FloorLaser
local HitByLaser = ReplicatedStorage.Remotes.FactoryBoss.HitByLaser
local QuadLaser = ReplicatedStorage.Remotes.FactoryBoss.QuadLaser

local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local Interval = require(ReplicatedStorage.Core.Interval)
local Maid = require(ReplicatedStorage.Core.Maid)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)
local TakeDamage = require(ServerScriptService.Shared.TakeDamage)

local DAMAGE_BUFF = 1.125
local FINALE_CRUMBLE = 1.4
local FINALE_TIME = 3
local FLOOR_LASER = 5
local HEALTH_COLOR_BLINK_HEALTH = 0.1
local HEALTH_COLOR_BLINK_RATE = 0.2
local TUBES = 4

local BLACK = Color3.new()
local RED = Color3.fromRGB(231, 76, 60)

PhysicsService:CreateCollisionGroup("FactoryBoss")
PhysicsService:CollisionGroupSetCollidable("FactoryBoss", "FactoryBoss", false)

local FactoryBoss = {}
FactoryBoss.__index = FactoryBoss

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
		hitByFloor = {},
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
			local damage = self:GetScale("BaseSpinDamage")
			TakeDamage(player, damage * DAMAGE_BUFF ^ getLevels(self.instance.Humanoid))
		end
	end)

	QuadLaser.OnServerEvent:connect(function(player)
		local character = player.Character
		if character then
			local damage = self:GetScale("QuadLaserDamage")
			TakeDamage(player, damage * DAMAGE_BUFF ^ getLevels(self.instance.Humanoid))
		end
	end)

	FloorLaser.OnServerEvent:connect(function(player)
		if not self.hitByFloor[player] then
			self.hitByFloor[player] = true

			TakeDamage(
				player,
				self:GetScale("FloorLaserDamage")
					* DAMAGE_BUFF
					^ getLevels(self.instance.Humanoid)
			)
		end
	end)

	RealDelay(math.random(3, 6), function()
		Interval(self:GetScale("QuadLaserRateOfFire"), function()
			if self.alive then
				self:QuadLaser()
			end

			return self.alive
		end)
	end)

	FastSpawn(function()
		wait(math.random(1, 3))
		while self.alive do
			self:FloorLaser()
			wait(FLOOR_LASER)
		end
	end)
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

function FactoryBoss:FloorLaser()
	self.hitByFloor = {}
	FloorLaser:FireAllClients()
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

	QuadLaser:FireAllClients()
	wait(self:GetScale("QuadLaserTime") + self:GetScale("QuadLaserChargeTime"))
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

function FactoryBoss.EmitFire()
	local particles = CollectionService:GetTagged("FinaleExplode")
	particles[math.random(#particles)]:Emit(math.random(2, 4))
end

function FactoryBoss.UpdateNametag() end

return FactoryBoss
