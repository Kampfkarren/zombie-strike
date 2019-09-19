local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local DungeonState = require(ServerScriptService.DungeonState)
local Maid = require(ReplicatedStorage.Core.Maid)
local Nametag = require(ServerScriptService.Shared.Nametag)
local XP = require(ReplicatedStorage.Core.XP)

local AMOUNT_FOR_NOT_BOSS = 0.7
local DEBUG = true

local Zombie = {}
Zombie.__index = Zombie

Zombie.AIAggroCheckTime = 0.35
Zombie.AIAggroRange = 60

Zombie.AttackCheckInterval = 0.1
Zombie.AttackCooldown = 3
Zombie.AttackRange = 5

Zombie.WanderSpeed = 5

function Zombie:Destroy()
	self.maid:DoCleaning()
end

function Zombie.Debug(_, message)
	if DEBUG then
		print("🧟‍: " .. message)
	end
end

function Zombie:Spawn(position)
	self.instance:SetPrimaryPartCFrame(CFrame.new(position))
	self.instance.Name = self.Name
	self.instance.Parent = Workspace.Zombies

	self.aliveMaid:GiveTask(ReplicatedStorage.RuddevEvents.Damaged.Event:connect(function(humanoid)
		if humanoid == self.instance.Humanoid then
			self:UpdateNametag()
		end
	end))

	local humanoid = self.instance.Humanoid
	local health = self:GetHealth()
	humanoid.MaxHealth = health
	humanoid.Health = health

	humanoid.Died:connect(function()
		self:UpdateNametag()
		self:Die()
	end)

	self.aliveMaid:GiveTask(
		ReplicatedStorage.RuddevEvents.Damaged.Event:connect(function(damaged, damage, damagedBy)
			if damaged == humanoid then
				self.damagedEvent:Fire(damage, damagedBy)
			end
		end)
	)

	for _, part in pairs(self.instance:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function()
				part:SetNetworkOwner()
			end)
		end
	end

	self:UpdateNametag()
	self:InitializeAI()
	self:AfterSpawn()

	return self.instance
end

function Zombie:InitializeAI()
	self.defaultAiInitialized = true

	self:Wander()

	self.aliveMaid:GiveTask(self.Damaged:connect(function(_, damagedBy)
		if self.wandering then
			self.lastAttacker = damagedBy
			self:Aggro()
		end
	end))

	spawn(function()
		while self.instance.Humanoid.Health > 0 do
			wait(math.random(30, 50) / 10)

			local headBump = Workspace:FindPartOnRay(
				Ray.new(
					self.instance.Head.Position,
					self.instance.Head.CFrame.UpVector * 4
				)
			)

			if headBump then
				self:Debug("can't jump, something above")
			else
				local oldJumpPower = self.instance.Humanoid.JumpPower
				self.instance.Humanoid.JumpPower = 40
				self.instance.Humanoid.Jump = true
				RunService.Heartbeat:wait()
				RunService.Heartbeat:wait()
				self.instance.Humanoid.JumpPower = oldJumpPower
			end
		end
	end)
end

function Zombie:Wander()
	if not self.defaultAiInitialized then return end
	self.aggroTick = self.aggroTick + 1

	local humanoid = self.instance.Humanoid
	humanoid.WalkSpeed = self.WanderSpeed

	local noiseX = math.random()
	local noiseY = math.random()

	self.wandering = true

	spawn(function()
		while self.wandering do
			humanoid:Move(Vector3.new(
				math.noise(noiseX) * 2,
				0,
				math.noise(noiseY) * 2
			))

			noiseX = noiseX + 1 / 15
			noiseY = noiseY + 1 / 15

			wait(1)
		end
	end)

	spawn(function()
		wait(math.random(40, 60) / 100)
		while self.wandering do
			for _, player in pairs(Players:GetPlayers()) do
				local character = player.Character
				if character and character.Humanoid.Health > 0 then
					if (character.PrimaryPart.Position - self.instance.PrimaryPart.Position).Magnitude <= self.AIAggroRange then
						self:Aggro(character)
					end
				end
			end

			wait(self.AIAggroCheckTime)
		end
	end)
end

-- AGGRO
function Zombie:Aggro(focus)
	if not self.defaultAiInitialized then return end
	local humanoid = self.instance.Humanoid
	humanoid.WalkSpeed = self:GetSpeed()

	self:AssignAggroFocus(focus)
	local focus = self.aggroFocus
	if not focus then return end

	self.wandering = false

	local ourTick = self.aggroTick + 1
	self.aggroTick = ourTick

	local pathing = PathfindingService:CreatePath()

	local waypoints = {}

	spawn(function()
		while self.aggroTick == ourTick and self.aggroFocus:IsDescendantOf(game) do
			local waypoint = table.remove(waypoints, 1)
			if waypoint then
				if waypoint.Action == Enum.PathWaypointAction.Jump then
					humanoid.Jump = true
				elseif waypoint.Action == Enum.PathWaypointAction.Walk then
					local diff = waypoint.Position - self.instance.PrimaryPart.Position
					local angle = math.atan2(diff.X, diff.Z)

					if (math.abs(math.deg(angle)) < 120 and diff.Magnitude > 5) or #waypoints == 0 then
						humanoid:MoveTo(waypoint.Position)
						humanoid.MoveToFinished:wait()
					end
				end
			else
				wait(0.15)
			end
		end
	end)

	spawn(function()
		wait(math.random(40, 60) / 100)
		while self.aggroTick == ourTick do
			pathing:ComputeAsync(self.instance.PrimaryPart.Position, focus.PrimaryPart.Position)
			waypoints = pathing:GetWaypoints()

			wait(0.25)
		end
	end)

	spawn(function()
		wait(math.random(40, 60) / 100)
		while self.aggroTick == ourTick do
			if self:CheckAttack() then
				wait(self.AttackCooldown)
			else
				wait(self.AttackCheckInterval)
			end
		end
	end)
end

function Zombie:AssignAggroFocus(force)
	local players = Players:GetPlayers()
	if #players == 0 then
		self:Debug("AssignAggroFocus: All players have left")
		self.aggroFocus = nil
		self:Wander()
		return
	end

	if force then
		self.aggroFocus = force
	else
		self.aggroFocus = nil

		if self.lastAttacker then
			local character = self.lastAttacker.Character
			if character then
				self.aggroFocus = character
			end
		end

		if not self.aggroFocus then
			while #players > 0 do
				local player = table.remove(players, math.random(#players))
				local character = player.Character
				if character and character.Humanoid.Health > 0 then
					self.aggroFocus = character
				end
			end
		end
	end

	if self.aggroFocus then
		self.aliveMaid:GiveTask(self.aggroFocus.Humanoid.Died:connect(function()
			self:AssignAggroFocus()
		end))

		return
	end

	self:Debug("AssignAggroFocus: All players have died")
	self:Wander()
end
-- END AGGRO

function Zombie:CheckAttack()
	if (self.instance.HumanoidRootPart.Position - self.aggroFocus.PrimaryPart.Position).Magnitude <= self.AttackRange then
		return self:Attack()
	end
end

function Zombie:Die()
	self.alive = false
	self.instance.Humanoid.Health = 0
	self.diedEvent:Fire()
	self.aliveMaid:DoCleaning()
	ReplicatedStorage.Remotes.KillEnemy:FireAllClients(self.instance)
	self:GiveXP()
	self:AfterDeath()
end

-- START XP
function Zombie:GiveXP()
	local xpGain = self:GetXP()
	if xpGain > 0 then
		ReplicatedStorage.Remotes.XPGain:FireAllClients(self.instance.PrimaryPart.Position, math.floor(xpGain))
		for _, player in pairs(Players:GetPlayers()) do
			local playerData = player:FindFirstChild("PlayerData")
			if playerData then
				local level = playerData.Level
				local xp = playerData.XP

				local xpNeeded = XP.XPNeededForNextLevel(level.Value)
				if xp.Value + xpGain >= xpNeeded then
					level.Value = level.Value + 1
					xp.Value = 0
					ReplicatedStorage.Remotes.LevelUp:FireAllClients(player)
				else
					xp.Value = xp.Value + xpGain
				end
			end
		end
	end
end

function Zombie:GetXP()
	return (Dungeon.GetDungeonData("DifficultyInfo").XP * AMOUNT_FOR_NOT_BOSS) / DungeonState.NormalZombies
end
-- END XP

-- START STATS
function Zombie:GetScale(key)
	local scale = assert(self.Scaling[key] or self:CustomScale(key), "no scale for " .. key)
	return scale.Base * scale.Scale ^ (self.level - 1)
end

function Zombie:GetHealth()
	return self:GetScale("Health")
end

function Zombie:GetSpeed()
	return self:GetScale("Speed")
end
-- END STATS

function Zombie:UpdateNametag()
	return Nametag(self.instance, self.level)
end

-- START BASIC HOOKS
function Zombie.CustomScale() end
function Zombie.AfterDeath() end
function Zombie.AfterSpawn() end
-- END BASIC HOOKS

function Zombie.new(zombieType, level, ...)
	assert(zombieType)
	local originalZombie = require(script.Parent[zombieType])
	assert(originalZombie)

	local zombie = originalZombie.new(level, ...)

	local instance = ServerStorage.Zombies[Dungeon.GetDungeonData("Campaign")][zombie.Model]:Clone()

	local aliveMaid = Maid.new()

	local maid = Maid.new()
	maid:GiveTask(instance)
	maid:GiveTask(aliveMaid)

	local damagedEvent = Instance.new("BindableEvent")
	local diedEvent = Instance.new("BindableEvent")

	return setmetatable({
		alive = true,
		aliveMaid = aliveMaid,
		aggroTick = 0,
		damagedEvent = damagedEvent,
		diedEvent = diedEvent,
		instance = instance,
		level = level,
		maid = maid,

		Damaged = damagedEvent.Event,
		Died = diedEvent.Event,
	}, {
		__index = function(_, key)
			return zombie[key]
				or Zombie[key]
		end,
	})
end

return Zombie
