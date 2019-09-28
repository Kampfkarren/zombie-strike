-- services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- constants

local EVENTS = ReplicatedStorage:WaitForChild("RuddevEvents")
local MODULES = ReplicatedStorage:WaitForChild("RuddevModules")
	local CONFIG = require(MODULES:WaitForChild("Config"))

local DAMAGE = {}

if not ReplicatedStorage.HubWorld.Value then
	local Data = require(ReplicatedStorage.Core.Data)

	local CRIT_MULTIPLIER = 2

	function DAMAGE.Calculate(_, item, hit, origin)
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

	function DAMAGE.PlayerCanDamage(_, _, humanoid)
		if humanoid:FindFirstChild("NoKill") then return end
		return Players:GetPlayerFromCharacter(humanoid.Parent) == nil and humanoid.Health > 0
	end

	function DAMAGE.Damage(_, humanoid, damage, player, critChance)
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
			local crit = true

			if math.random() <= critChance / 100 then
				damage = damage * CRIT_MULTIPLIER
				crit = true
			end

			humanoid:TakeDamage(damage)
			EVENTS.Damaged:Fire(humanoid, damage, player)
			ReplicatedStorage.Remotes.DamageNumber:FireAllClients(humanoid, damage, crit)
		end
	end
else
	function DAMAGE.PlayerCanDamage()
		return false
	end
end

return DAMAGE