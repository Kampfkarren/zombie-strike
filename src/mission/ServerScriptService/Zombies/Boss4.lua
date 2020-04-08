local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Maid = require(ReplicatedStorage.Core.Maid)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)
local TakeDamage = require(ServerScriptService.Shared.TakeDamage)

local IcicleRain = ReplicatedStorage.Remotes.FrostlandsBoss.IcicleRain
local Slam = ReplicatedStorage.Remotes.FrostlandsBoss.Slam
local Spin = ReplicatedStorage.Remotes.FrostlandsBoss.Spin

local BOSS_DEATH_DELAY = 4.5
local FREEZE_TIME = 2

local FrostlandsBoss = {}
FrostlandsBoss.__index = FrostlandsBoss

FrostlandsBoss.Name = "Yeti Zombie"
FrostlandsBoss.Model = "Boss"

function FrostlandsBoss.new()
	return setmetatable({}, FrostlandsBoss)
end

function FrostlandsBoss.InitializeAI() end

function FrostlandsBoss:AfterDeath()
	self.instance.Humanoid:LoadAnimation(
		ReplicatedStorage.Assets.Campaign.Campaign4.Boss.DeathAnimation
	):Play()

	wait(BOSS_DEATH_DELAY)

	self:Destroy()
end

function FrostlandsBoss:AfterSpawn()
	local instance = self.instance

	self.roarAnimation = instance.Humanoid:LoadAnimation(
		ReplicatedStorage
			.Assets
			.Campaign
			.Campaign4
			.Boss
			.RoarAnimation
	)

	instance:SetPrimaryPartCFrame(
		instance.PrimaryPart.CFrame
		* CFrame.Angles(0, math.pi * (2 / 3), 0)
	)
end

function FrostlandsBoss:InitializeBossAI(room)
	self.bossRoom = room

	IcicleRain.OnServerEvent:connect(function(player)
		TakeDamage(player, self:GetScale("IcicleDamage"))
	end)

	Spin.OnServerEvent:connect(function(player)
		TakeDamage(player, self:GetScale("SpinAttackDamage"))
	end)

	Slam.OnServerEvent:connect(function(player)
		TakeDamage(player, self:GetScale("SlamAttackDamage"))
	end)

	wait(1.5)

	local currentSequence = 1

	while self.alive do
		FrostlandsBoss.AttackSequence[currentSequence](self)
		currentSequence = (currentSequence % #FrostlandsBoss.AttackSequence) + 1
		wait(4)
	end
end

function FrostlandsBoss:SummonZombies()
	self.roarAnimation:Play()
	self.instance.PrimaryPart.Freezing.Enabled = true

	local running = coroutine.running()

	RealDelay(FREEZE_TIME, function()
		local freezeSound = SoundService.ZombieSounds["4"].Boss.FreezeSelf:Clone()
		freezeSound.Parent = Workspace
		freezeSound.PlayOnRemove = true
		freezeSound:Destroy()

		local maid = Maid.new()
		self.instance.PrimaryPart.Freezing.Enabled = false

		local frozen = ReplicatedStorage.Assets.Campaign.Campaign4.Boss.Frozen:Clone()
		frozen.Position = self.instance.PrimaryPart.Position
		frozen.Parent = Workspace

		local healed = 0
		local healConnection
		healConnection = RunService.Heartbeat:connect(function(delta)
			local healAmount = delta * self:GetScale("SummonHeal")
			healed = healed + healAmount

			if healed >= self:GetScale("SummonMaxHeal") then
				healConnection:disconnect()
			elseif self.alive then
				local humanoid = self.instance.Humanoid
				humanoid.Health = humanoid.Health + (humanoid.MaxHealth * (healAmount / 100))
			end
		end)
		maid:GiveTask(healConnection)

		maid:GiveTask(frozen)

		local noKill = Instance.new("Model")
		noKill.Name = "NoKill"
		noKill.Parent = self.instance.Humanoid
		maid:GiveTask(noKill)

		local summonCount = self:GetScale("SummonCount")
		local zombiesLeft = summonCount

		for _ = 1, summonCount do
			self:SummonGoon(function(zombie)
				zombie.Died:connect(function()
					zombiesLeft = zombiesLeft - 1

					if zombiesLeft == 0 then
						maid:DoCleaning()
						coroutine.resume(running)
					end
				end)
			end)
		end
	end)

	coroutine.yield()
end

function FrostlandsBoss.Slam()
	Slam:FireAllClients()
end

function FrostlandsBoss.Spin()
	Spin:FireAllClients()
end

function FrostlandsBoss:IcicleRain()
	IcicleRain:FireAllClients()
	wait(self:GetScale("IcicleTimer"))
end

FrostlandsBoss.AttackSequence = {
	FrostlandsBoss.Spin,
	FrostlandsBoss.IcicleRain,
	FrostlandsBoss.Slam,
	FrostlandsBoss.SummonZombies,
}

return FrostlandsBoss
