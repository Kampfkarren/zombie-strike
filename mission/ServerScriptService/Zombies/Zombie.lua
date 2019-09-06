local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Maid = require(ReplicatedStorage.Core.Maid)
local XP = require(ReplicatedStorage.Core.XP)

local Zombie = {}
Zombie.__index = Zombie

Zombie.AIAggroCheckTime = 0.35
Zombie.AIAggroRange = 30

Zombie.AttackCheckInterval = 0.1
Zombie.AttackCooldown = 3
Zombie.AttackRange = 5

Zombie.WanderSpeed = 5

function Zombie:Destroy()
	self.maid:DoCleaning()
end

function Zombie:Spawn(position)
	self.instance:SetPrimaryPartCFrame(CFrame.new(position))
	self.instance.Parent = Workspace.Zombies

	self.aliveMaid:GiveTask(ReplicatedStorage.RuddevEvents.Damaged.Event:connect(function(humanoid)
		if humanoid == self.instance.Humanoid then
			self:UpdateNametag()
		end
	end))

	local humanoid = self.instance.Humanoid
	local health = self:GetScale("Health")
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
	self:Wander()

	self.aliveMaid:GiveTask(self.Damaged:connect(function(_, damagedBy)
		if self.wandering then
			self.lastAttacker = damagedBy
			self:Aggro()
		end
	end))
end

function Zombie:Wander()
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
	local humanoid = self.instance.Humanoid
	humanoid.WalkSpeed = self:GetScale("Speed")

	self:AssignAggroFocus(focus)
	local focus = self.aggroFocus
	if not focus then return end

	self.wandering = false

	local ourTick = self.aggroTick + 1
	self.aggroTick = ourTick

	local pathing = PathfindingService:CreatePath({
		AgentCanJump = false,
	})

	local waypoints = {}

	spawn(function()
		while self.aggroTick == ourTick and self.aggroFocus:IsDescendantOf(game) do
			local waypoint = table.remove(waypoints)
			if waypoint then
				humanoid:MoveTo(waypoint.Position)
				wait(0.2)
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

			wait(0.15)
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
		warn("AssignAggroFocus: All players have left")
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

	warn("AssignAggroFocus: All players have died")
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
	self.diedEvent:Fire()
	self.aliveMaid:DoCleaning()
	ReplicatedStorage.Remotes.KillEnemy:FireAllClients(self.instance)
	self:GiveXP()
end

-- START XP
function Zombie:GiveXP()
	local xpGain = self:GetXP()
	if xpGain > 0 then
		ReplicatedStorage.Remotes.XPGain:FireAllClients(self.instance.PrimaryPart.Position, xpGain)
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
	return 400
end
-- END XP

function Zombie:GetScale(key)
	local scale = assert(self.Scaling[key], "no scale for " .. key)
	return scale.Base * scale.Scale ^ (self.level - 1)
end

function Zombie:UpdateNametag()
	local nametag = self.nametag

	if not nametag then
		nametag = ServerStorage.Nametag:Clone()
		nametag.Parent = self.instance.Head
		self.nametag = nametag
	end

	local humanoid = self.instance.Humanoid
	nametag.Health.HealthNumber.Text = ("%d/%d"):format(
		humanoid.Health,
		humanoid.MaxHealth
	)
	nametag.Health.Fill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)

	nametag.EnemyName.Text = self.Name
	nametag.Level.Text = "LV. " .. self.level

	return nametag
end

-- START BASIC HOOKS
function Zombie:AfterSpawn() end
-- END BASIC HOOKS

function Zombie.new(zombieType, level, ...)
	assert(zombieType)
	local originalZombie = require(script.Parent[zombieType])
	assert(originalZombie)

	local zombie = originalZombie.new(level, ...)

	local instance = zombie.Model:Clone()

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
