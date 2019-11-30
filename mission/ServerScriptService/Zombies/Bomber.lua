local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Common = require(script.Parent.Common)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local Equip = require(ServerScriptService.Shared.Ruddev.Equip)
local TakeDamage = require(ServerScriptService.Shared.TakeDamage)

local BomberZombieEffect = ReplicatedStorage.Remotes.Zombies.BomberZombieEffect

local EXPLOSION_RANGE = 30

local Bomber = {}
Bomber.__index = Bomber

Bomber.AttackRange = 15

function Bomber.new(level)
	return setmetatable({
		Model = "Bomber",
		_derivative = Common.new(level),
	}, {
		__index = function(self, key)
			return Bomber[key] or self._derivative[key]
		end,
	})
end

function Bomber:Attack()
	local position = self.instance.PrimaryPart.Position
	local fire = self.bomb:FindFirstChild("Fire", true)

	self.bomb.PrimaryPart.Fuse:Play()
	fire.Enabled = true
	wait(self:GetScale("Delay"))
	self.bomb.PrimaryPart.Fuse:Stop()
	fire.Enabled = false
	if not self.alive then return end
	self.bomb.PrimaryPart.Explosion:Play()
	BomberZombieEffect:FireAllClients(self.instance)
	self:Die()

	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character
		if character
			and character.Humanoid.Health > 0
			and (character.PrimaryPart.Position - position).Magnitude <= EXPLOSION_RANGE
		then
			TakeDamage(player, self:GetScale("Damage"))
		end
	end

	return true
end

function Bomber:AfterSpawn()
	local bomb = ReplicatedStorage
		.Assets
		.Campaign["Campaign" .. Dungeon.GetDungeonData("Campaign")]
		.Bomber
		.Bomb:Clone()

	bomb.Parent = self.instance
	Equip(bomb)
	self.bomb = bomb
end

function Bomber:AfterDeath()
	local fire = self.bomb:FindFirstChild("Fire", true)
	if fire then
		fire:Destroy()
	end
end

return Bomber
