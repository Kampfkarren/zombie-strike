-- services

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- constants

local EVENTS = ReplicatedStorage:WaitForChild("RuddevEvents")
local REMOTES = ReplicatedStorage:WaitForChild("RuddevRemotes")
local MODULES = ReplicatedStorage:WaitForChild("RuddevModules")
	local CONFIG = require(MODULES:WaitForChild("Config"))

local Data = require(ReplicatedStorage.Libraries.Data)

local CRIT_MULTIPLIER = 1.5

-- functions

-- module

local DAMAGE = {}

-- variables

local damageEnabled = true

-- todo: implement damage functions etc

function DAMAGE.SetEnabled(self, enabled)
	damageEnabled = enabled
end

function DAMAGE.Calculate(self, item, hit, origin)
	local config = CONFIG:GetConfig(item)
	local damage = config.Damage

	if hit.Name == "Head" then
		damage = damage * 1.2
	end

	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid:FindFirstChild("Down") then
		if humanoid.Down.Value then
			damage = damage * 2
		end
	end

	local distance = (origin - hit.Position).Magnitude
	local falloff = math.clamp(1 - (distance / config.Range)^3, 0, 1)
	local minDamage = damage * 0.3
	damage = math.max(damage * falloff, minDamage)

	return math.ceil(damage)
end

function DAMAGE.PlayerCanDamage(self, player, humanoid)
	return Players:GetPlayerFromCharacter(humanoid.Parent) == nil
end

function DAMAGE.Damage(self, humanoid, damage, player)
	local armor = humanoid:FindFirstChild("Armor")

	if player then
		local killTag = humanoid:FindFirstChild("KillTag")

		if not killTag then
			killTag = Instance.new("ObjectValue")
				killTag.Name = "KillTag"
				killTag.Parent = humanoid
		end

		killTag.Value = player
	end

	if humanoid.Health > 0 then
		local gun = Data.GetPlayerData(player, "Weapon")
		local crit

		if gun then
			local critChance = gun.CritChance
			if math.random() <= critChance then
				damage = damage * CRIT_MULTIPLIER
				crit = true
			end
		end

		humanoid:TakeDamage(damage)
		EVENTS.Damaged:Fire(humanoid, damage)
		ReplicatedStorage.Remotes.DamageNumber:FireAllClients(humanoid, damage, crit)
	end
end

return DAMAGE