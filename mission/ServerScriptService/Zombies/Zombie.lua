local Debris = game:GetService("Debris")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Buffs = require(ServerScriptService.Libraries.Buffs)
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
	local humanoid = self.instance.Humanoid
	self.instance:SetPrimaryPartCFrame(CFrame.new(position))
	self.instance.Name = self:GetName()
	self.instance.Parent = Workspace.Zombies

	local primaryPart = self.instance.PrimaryPart
	primaryPart.AncestryChanged:connect(function()
		if not primaryPart:IsDescendantOf(game) then
			self:Die()
		end
	end)

	self.aliveMaid:GiveTask(ReplicatedStorage.RuddevEvents.Damaged.Event:connect(function(humanoid)
		if humanoid == self.instance.Humanoid then
			self:UpdateNametag()
		end
	end))

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

	self:SetupHumanoid()
	self:UpdateNametag()
	self:InitializeAI()
	self:AfterSpawn()

	return self.instance
end

function Zombie:SetupHumanoid()
	local humanoid = self.instance.Humanoid
	local health = self:GetHealth()
	humanoid.MaxHealth = health
	humanoid.Health = health

	humanoid.Died:connect(function()
		self:UpdateNametag()
		self:Die()
	end)
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
		wait(math.random(30, 50) / 10)

		while self.alive do
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

			wait(math.random(30, 50) / 10)
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
					if (character.PrimaryPart.Position - self.instance.PrimaryPart.Position).Magnitude
						<= Dungeon.GetDungeonData("CampaignInfo").AIAggroRange
					then
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

	spawn(function()
		local waypoints = {}
		local lastRecalculate = 0

		while self.alive
			and self.aggroTick == ourTick
			and self.aggroFocus:IsDescendantOf(game)
			and self.aggroFocus.Humanoid.Health > 0
		do
			repeat
				if tick() - lastRecalculate > 0.25 then
					pathing:ComputeAsync(self.instance.PrimaryPart.Position, focus.PrimaryPart.Position)

					if not (self.alive
						and self.aggroTick == ourTick
						and self.aggroFocus:IsDescendantOf(game)
						and self.aggroFocus.Humanoid.Health > 0
					) then
						break -- continue
					end

					waypoints = pathing:GetWaypoints()
					lastRecalculate = tick()
				end

				local waypoint = table.remove(waypoints, 1)
				if waypoint then
					if waypoint.Action == Enum.PathWaypointAction.Jump then
						humanoid.Jump = true
					elseif waypoint.Action == Enum.PathWaypointAction.Walk then
						local diff = waypoint.Position - self.instance.PrimaryPart.Position
						local angle = math.atan2(diff.X, diff.Z)

						if (math.abs(math.deg(angle)) < 120 and diff.Magnitude > 5) or #waypoints == 0 then
							humanoid:MoveTo(waypoint.Position, self.aggroFocus.PrimaryPart)
							humanoid.MoveToFinished:wait()
						end
					end
				else
					wait(0.15)
				end
			until true
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
	if self.alive and
		(
			self.instance.HumanoidRootPart.Position - self.aggroFocus.PrimaryPart.Position
		).Magnitude <= self.AttackRange
	then
		return self:Attack()
	end
end

function Zombie:Die()
	if not self.alive then return end
	self.alive = false
	self.instance.Humanoid.Health = 0
	self.aliveMaid:DoCleaning()
	ReplicatedStorage.Remotes.KillEnemy:FireAllClients(self.instance)
	for _, player in pairs(Players:GetPlayers()) do
		ServerStorage.Events.GiveQuest:Fire(player, "KillZombies", 1)
	end
	self:GiveXP()
	self:PlayDeathSound()
	self:MaybeDropBuff()
	self:AfterDeath()
	self.diedEvent:Fire()
end

function Zombie:MaybeDropBuff()
	local primaryPart = self.instance.PrimaryPart
	if primaryPart then
		Buffs.MaybeDropBuff(primaryPart.Position)
	end
end

function Zombie:LoadAnimation(animation)
	return self.instance.Humanoid:LoadAnimation(animation)
end

-- START XP
function Zombie:GiveXP()
	local xpGain = self:GetXP()

	if xpGain > 0 then
		for _, player in pairs(Players:GetPlayers()) do
			local playerData = player:FindFirstChild("PlayerData")

			if playerData then
				local level = playerData.Level
				local xp = playerData.XP
				local xpGain = xpGain * playerData.XPScale.Value

				local xpNeeded = XP.XPNeededForNextLevel(level.Value)
				if xp.Value + xpGain >= xpNeeded then
					level.Value = level.Value + 1
					xp.Value = 0
					ReplicatedStorage.Remotes.LevelUp:FireAllClients(player)
				else
					xp.Value = xp.Value + xpGain
				end

				local primaryPart = self.instance.PrimaryPart
				if primaryPart then
					ReplicatedStorage.Remotes.XPGain:FireClient(
						player,
						primaryPart.Position,
						math.floor(xpGain)
					)
				end
			end
		end
	end
end

function Zombie.GetXP()
	return (Dungeon.GetDungeonData("DifficultyInfo").XP * AMOUNT_FOR_NOT_BOSS) / DungeonState.NormalZombies
end
-- END XP

-- START STATS
function Zombie:GetScaling()
	local campaignInfo = Dungeon.GetDungeonData("CampaignInfo")
	return assert(campaignInfo.Stats[self.zombieType])
end

function Zombie:GetScale(key)
	local campaignInfo = Dungeon.GetDungeonData("CampaignInfo")

	local scale = assert(
		(self.Scaling or self:GetScaling())[key]
			or self:CustomScale(key),
		"no scale for " .. key
	)

	return scale.Base * scale.Scale ^ (self.level - campaignInfo.Difficulties[1].MinLevel)
end

function Zombie:GetScaleSafe(key)
	local success, scale = pcall(function()
		return self:GetScale(key)
	end)

	return success and scale
end

function Zombie:GetHealth()
	local health = self:GetScale("Health")
	health = health * (1 + (0.35 * (#Players:GetPlayers() - 1)))
	return health
end

function Zombie:GetDamageAgainst(player)
	return self:GetDamageAgainstConstant(
		player,
		self:GetScale("Damage"),
		self:GetScaleSafe("MaxHealthDamage")
	)
end

function Zombie.GetDamageAgainstConstant(_, player, damage, maxHpDamage)
	if maxHpDamage then
		local character = player.Character
		if character then
			damage = damage + character.Humanoid.MaxHealth * (maxHpDamage / 100)
		end
	end

	return damage
end

function Zombie:GetSpeed()
	return self:GetScale("Speed")
end
-- END STATS

function Zombie:GetName()
	return self.Name
		or self:GetModel().ZombieName.Value
end

function Zombie:GetAsset(assetName)
	return ReplicatedStorage
		.Assets
		.Campaign["Campaign" .. Dungeon.GetDungeonData("Campaign")]
		[self.Model]
		[assetName]
end

function Zombie:UpdateNametag()
	return Nametag(self.instance, self.level)
end

-- START BASIC HOOKS
function Zombie.CustomScale() end
function Zombie.AfterDeath() end
function Zombie.AfterSpawn() end
-- END BASIC HOOKS

-- START SOUNDS
function Zombie.GetDeathSound()
	local sounds = SoundService.ZombieSounds[Dungeon.GetDungeonData("Campaign")].Death:GetChildren()
	return sounds[math.random(#sounds)]:Clone()
end

function Zombie:PlayDeathSound()
	local sound = self:GetDeathSound()
	sound.Parent = self.instance.PrimaryPart
	sound:Play()
	Debris:AddItem(sound)
end
-- END SOUNDS

function Zombie:GetModel()
	return ServerStorage.Zombies[Dungeon.GetDungeonData("Campaign")][self.Model]:Clone()
end

function Zombie.new(zombieType, level, ...)
	assert(zombieType)
	local originalZombie = require(script.Parent[zombieType])
	assert(originalZombie)

	local zombie = originalZombie.new(level, ...)

	local instance = (zombie.GetModel or Zombie.GetModel)(zombie)

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
		zombieType = zombieType,

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
