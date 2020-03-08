local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local PlayQuickSound = require(ReplicatedStorage.Core.PlayQuickSound)
local TakeDamage = require(ServerScriptService.Shared.TakeDamage)

local BOSS_DEATH_DELAY = 2.5

local RANDOM_ATTACK_COOLDOWN = 2
local RANDOM_ATTACK_COUNT = 2

local FlameBreath = ReplicatedStorage.Remotes.Tower.Boss.FlameBreath
local MagicMissiles = ReplicatedStorage.Remotes.Tower.Boss.MagicMissiles
local MissileRing = ReplicatedStorage.Remotes.Tower.Boss.MissileRing

local ULTRA_ZOMBIE_COUNT = 2
local ULTRA_ZOMBIE_RANGE = 10

local TowerBoss = {}
TowerBoss.__index = TowerBoss

TowerBoss.Name = "The Summoner Zombie"
TowerBoss.Model = "Boss"

TowerBoss.FlameBreathDuration = {
	3 + 0.83,
	4 + 0.83,
	4.2 + 0.83,
	4.4 + 0.83,
	4.6 + 0.83,
}

TowerBoss.FlameBreathDamage = {
	20,
	20,
	30,
	35,
	40,
}

TowerBoss.MagicMissilesDuration = {
	6,
	7,
	8,
	9,
	10,
}

TowerBoss.MagicMissilesDamage = {
	20,
	25,
	30,
	35,
	40,
}

TowerBoss.MissileRingDamage = {
	20,
	25,
	30,
	35,
	40,
}

TowerBoss.MissileRingDuration = {
	4,
	5,
	6,
	7,
	8,
}

TowerBoss.SummonCount = {
	7,
	8,
	9,
	10,
	11,
}

function TowerBoss.new()
	return setmetatable({}, TowerBoss)
end

function TowerBoss.InitializeAI() end

function TowerBoss:InitializeBossAI(room)
	self.bossRoom = room

	FlameBreath.OnServerEvent:connect(function(player)
		TakeDamage(
			player,
			self:GetDamageAgainstConstant(
				player,
				0,
				TowerBoss.FlameBreathDamage[Dungeon.GetDungeonData("Difficulty")]
			)
		)
	end)

	MagicMissiles.OnServerEvent:connect(function(player)
		TakeDamage(
			player,
			self:GetDamageAgainstConstant(
				player,
				0,
				TowerBoss.MagicMissilesDamage[Dungeon.GetDungeonData("Difficulty")]
			)
		)
	end)

	MissileRing.OnServerEvent:connect(function(player)
		TakeDamage(
			player,
			self:GetDamageAgainstConstant(
				player,
				0,
				TowerBoss.MissileRingDamage[Dungeon.GetDungeonData("Difficulty")]
			)
		)
	end)

	self:StartAttack()

	wait(1.5)
end

function TowerBoss:AfterDeath()
	pcall(function()
		self.instance.Humanoid:LoadAnimation(self:GetAsset("DeathAnimation")):Play()
	end)

	wait(BOSS_DEATH_DELAY)
	self:Destroy()
end

function TowerBoss:Disappear()
	local animation = self.instance.Humanoid:LoadAnimation(self:GetAsset("TeleOut"))
	animation.Stopped:connect(function()
		if self.alive then
			self.disappeared = true
			self.instance.Parent = nil
		end
	end)
	animation:Play()
	PlayQuickSound(SoundService.ZombieSounds["6"].Boss.Disappear, self.instance.PrimaryPart)
end

function TowerBoss:Reappear()
	self.disappeared = false
	self.instance.Parent = Workspace
	self.instance.Humanoid:LoadAnimation(self:GetAsset("TeleIn")):Play()
	self.instance.PrimaryPart.Magic:Emit(10)
	self.instance.PrimaryPart.Dust:Emit(10)
	PlayQuickSound(SoundService.ZombieSounds["6"].Boss.Appear, self.instance.PrimaryPart)
end

function TowerBoss:StartAttack()
	for _ = 1, RANDOM_ATTACK_COUNT do
		wait(RANDOM_ATTACK_COOLDOWN)
		if not self.alive then return end
		TowerBoss.RandomAttacks[math.random(#TowerBoss.RandomAttacks)](self)
	end

	wait(RANDOM_ATTACK_COOLDOWN)
	self:SummonZombies()
end

function TowerBoss:SummonZombies()
	local summonCount = TowerBoss.SummonCount[Dungeon.GetDungeonData("Difficulty")]
	local goonsLeft = summonCount

	for _ = 1, summonCount do
		self:SummonGoon(function(goon)
			goon.Died:connect(function()
				goonsLeft = goonsLeft - 1
				if goonsLeft == 0 then
					self:Reappear()
					self:StartAttack()
				end
			end)
		end)
	end

	self:Disappear()
end

function TowerBoss:Disappeared()
	return self.disappeared
end

function TowerBoss.FlameBreath()
	FlameBreath:FireAllClients()
	wait(TowerBoss.FlameBreathDuration[Dungeon.GetDungeonData("Difficulty")])
end

function TowerBoss.MagicMissiles()
	MagicMissiles:FireAllClients()
	wait(TowerBoss.MagicMissilesDuration[Dungeon.GetDungeonData("Difficulty")])
end

function TowerBoss:SummonUltraZombies()
	self.instance.Humanoid:LoadAnimation(self:GetAsset("SummonUltra")):Play()
	PlayQuickSound(SoundService.ZombieSounds["6"].Boss.Magic, self.instance.PrimaryPart)

	for _ = 1, ULTRA_ZOMBIE_COUNT do
		self:SummonGoon(function(goon)
			goon.instance:SetPrimaryPartCFrame(self.instance.PrimaryPart.CFrame
				+ Vector3.new(
					math.random(-ULTRA_ZOMBIE_RANGE, ULTRA_ZOMBIE_RANGE),
					0,
					math.random(-ULTRA_ZOMBIE_RANGE, ULTRA_ZOMBIE_RANGE)
				)
			)
		end, "Ultra")
	end
end

function TowerBoss.MissileRing()
	MissileRing:FireAllClients()
	wait(TowerBoss.MissileRingDuration[Dungeon.GetDungeonData("Difficulty")])
end

TowerBoss.RandomAttacks = {
	TowerBoss.MagicMissiles,
	TowerBoss.MissileRing,
	TowerBoss.FlameBreath,
	TowerBoss.SummonUltraZombies,
}

return TowerBoss
