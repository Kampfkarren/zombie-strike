local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

FrostlandsBoss.IcicleDamage = {
	[77] = {
		Base = 2760000,
		Max = 7,
	},

	[83] = {
		Base = 4032000,
		Max = 7.5,
	},

	[89] = {
		Base = 7776000,
		Max = 8,
	},

	[95] = {
		Base = 15360000,
		Max = 8.5,
	},

	[101] = {
		Base = 30308683,
		Max = 9,
	},
}

FrostlandsBoss.IcicleTimer = {
	[77] = 6,
	[83] = 7,
	[89] = 8,
	[95] = 9,
	[101] = 10,
}

FrostlandsBoss.SlamAttackDamage = {
	[77] = {
		Base = 2990000,
		Max = 8,
	},

	[83] = {
		Base = 4368000,
		Max = 8.5,
	},

	[89] = {
		Base = 8424000,
		Max = 9,
	},

	[95] = {
		Base = 16640000,
		Max = 9.5,
	},

	[101] = {
		Base = 32834407,
		Max = 10,
	},
}

FrostlandsBoss.SpinAttackDamage = {
	[77] = {
		Base = 2300000,
		Max = 7,
	},

	[83] = {
		Base = 3360000,
		Max = 7.5,
	},

	[89] = {
		Base = 6480000,
		Max = 8,
	},

	[95] = {
		Base = 12800000,
		Max = 8.5,
	},

	[101] = {
		Base = 25257236,
		Max = 9,
	},
}

FrostlandsBoss.SummonCount = {
	[77] = 7,
	[83] = 8,
	[89] = 9,
	[95] = 10,
	[101] = 11,
}

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
		local damage = FrostlandsBoss.IcicleDamage[self.level]

		TakeDamage(player, self:GetDamageAgainstConstant(
			player,
			damage.Base,
			damage.Max
		))
	end)

	Spin.OnServerEvent:connect(function(player)
		local damage = FrostlandsBoss.SpinAttackDamage[self.level]

		TakeDamage(player, self:GetDamageAgainstConstant(
			player,
			damage.Base,
			damage.Max
		))
	end)

	Slam.OnServerEvent:connect(function(player)
		local damage = FrostlandsBoss.SlamAttackDamage[self.level]

		TakeDamage(player, self:GetDamageAgainstConstant(
			player,
			damage.Base,
			damage.Max
		))
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

		maid:GiveTask(frozen)

		local noKill = Instance.new("Model")
		noKill.Name = "NoKill"
		noKill.Parent = self.instance.Humanoid
		maid:GiveTask(noKill)

		local summonCount = FrostlandsBoss.SummonCount[self.level]
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
	local timer = FrostlandsBoss.IcicleTimer[self.level]
	IcicleRain:FireAllClients(timer)
	wait(timer)
end

FrostlandsBoss.AttackSequence = {
	FrostlandsBoss.Spin,
	FrostlandsBoss.IcicleRain,
	FrostlandsBoss.Slam,
	FrostlandsBoss.SummonZombies,
}

return FrostlandsBoss
