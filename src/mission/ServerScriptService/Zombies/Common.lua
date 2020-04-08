local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local LineOfSight = require(ReplicatedStorage.Libraries.LineOfSight)
local TakeDamage = require(ServerScriptService.Shared.TakeDamage)

local ZombieAttack = ReplicatedStorage.Assets.Animations.ZombieAttack

local BasicZombie = {}
BasicZombie.__index = BasicZombie

BasicZombie.Model = "Zombie"

function BasicZombie:AfterSpawn()
	self._animations = {}

	for _, animation in ipairs(ZombieAttack:GetChildren()) do
		local animation = self.instance.Humanoid:LoadAnimation(animation)
		animation.KeyframeReached:connect(function()
			self:CommitAttack()
		end)
		table.insert(self._animations, animation)
	end

	self.aliveMaid:GiveTask(function()
		for _, animation in ipairs(self._animations) do
			animation:Stop()
		end
	end)
end

function BasicZombie:PlayAttackAnimation()
	local animations = self._animations
	animations[math.random(#animations)]:Play()
end

function BasicZombie:Attack()
	self:PlayAttackAnimation()
	return true
end

function BasicZombie:CommitAttack()
	if self.instance.Humanoid.Health <= 0 then return end
	local root = self.instance.PrimaryPart

	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character
		if LineOfSight(
			root,
			character,
			self.AttackRange,
			{ Workspace.Zombies }
		) then
			TakeDamage(player, self:GetDamageAgainst(player))
		end
	end
end

function BasicZombie.new()
	return setmetatable({}, BasicZombie)
end

-- TypeScript compatibility
BasicZombie.constructor = BasicZombie.new

return BasicZombie
