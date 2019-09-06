local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local LineOfSight = require(ServerScriptService.Libraries.LineOfSight)

local ZombieAttack = ReplicatedStorage.Assets.Animations.ZombieAttack

local BasicZombie = {}
BasicZombie.__index = BasicZombie

BasicZombie.Model = ServerStorage.Zombies.Zombie
BasicZombie.Name = "Zombie"

BasicZombie.Scaling = {
	Health = {
		Base = 70,
		Scale = 1.154,
	},

	Speed = {
		Base = 14.5,
		Scale = 1.01,
	},

	Damage = {
		Base = 25,
		Scale = 1.15,
	},
}

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
				character.Humanoid:TakeDamage(self:GetScale("Damage"))
			end
		end
	end)

	return true
end

function BasicZombie.new()
	return setmetatable({}, BasicZombie)
end

return BasicZombie
