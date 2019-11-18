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
BasicZombie.Name = "Zombie"

function BasicZombie:AfterSpawn()
	self._animation = self.instance.Humanoid:LoadAnimation(ZombieAttack)
	self.aliveMaid:GiveTask(function()
		self._animation:Stop()
	end)
end

function BasicZombie:Attack()
	self._animation:Play()

	delay(1, function()
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
				TakeDamage(player, self:GetScale("Damage"))
			end
		end
	end)

	return true
end

function BasicZombie.new()
	return setmetatable({}, BasicZombie)
end

return BasicZombie
