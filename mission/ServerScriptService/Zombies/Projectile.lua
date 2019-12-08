local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Common = require(script.Parent.Common)
local TakeDamage = require(ServerScriptService.Shared.TakeDamage)

local ProjectileZombieEffect = ReplicatedStorage.Remotes.Zombies.ProjectileZombieEffect

local Projectile = {}
Projectile.__index = Projectile

Projectile.AttackRange = 35
Projectile.Model = "Projectile"

function Projectile.new(level)
	return setmetatable({
		_deriative = Common.new(level),
	}, {
		__index = function(self, key)
			return Projectile[key] or self._deriative[key]
		end,
	})
end

function Projectile:AfterSpawn()
	self.aliveMaid:GiveTask(ProjectileZombieEffect.OnServerEvent:connect(function(player, owner)
		if owner == self.instance then
			TakeDamage(player, self:GetDamageAgainst(player))
		end
	end))

	self.animation = self.instance.Humanoid:LoadAnimation(self:GetAsset("Throw"))

	self.animation:GetMarkerReachedSignal("Throw"):connect(function()
		if self.alive then
			ProjectileZombieEffect:FireAllClients(self.instance)
		end
	end)
end

function Projectile:Attack()
	self.animation:Play()
	return true
end

return Projectile
