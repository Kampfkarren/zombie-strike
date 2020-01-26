local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TakeDamage = require(ServerScriptService.Shared.TakeDamage)

local GunslingerZombieEffect = ReplicatedStorage.Remotes.Zombies.GunslingerZombieEffect

local Gunslinger = {}
Gunslinger.__index = Gunslinger

Gunslinger.AttackCooldown = 2
Gunslinger.AttackRange = 25
Gunslinger.Model = "Gunslinger"

function Gunslinger.new()
	return setmetatable({}, Gunslinger)
end

function Gunslinger:AfterSpawn()
	local instance = self.instance
	local gun = instance.Gun

	local idleAnimation = self:LoadAnimation(gun.Animations.Idle)
	idleAnimation.Priority = Enum.AnimationPriority.Idle
	idleAnimation.Looped = true
	idleAnimation:Play()

	local aimAnimation = self:LoadAnimation(gun.Animations.Aim)
	aimAnimation.Priority = Enum.AnimationPriority.Idle
	aimAnimation.Looped = true

	self.aimAnimation = aimAnimation
	self.reloadAnimation = self:LoadAnimation(gun.Animations.Reload)
	self.shootAnimation = self:LoadAnimation(gun.Animations.AimShoot)

	self.aliveMaid:GiveTask(GunslingerZombieEffect.OnServerEvent:connect(function(player)
		TakeDamage(player, self:GetDamageAgainst(player))
	end))
end

function Gunslinger:Attack()
	self.aimAnimation:Play()
	GunslingerZombieEffect:FireAllClients(self.instance)
	wait(self:GetScale("ActivationTime"))
	if not self.alive then return end
	GunslingerZombieEffect:FireAllClients(self.instance, true)
	self.aimAnimation:Stop()
	self.shootAnimation:Play()

	return true
end

function Gunslinger:GetAttackCooldown()
	return Gunslinger.AttackCooldown + self:GetScale("ActivationTime")
end

return Gunslinger
