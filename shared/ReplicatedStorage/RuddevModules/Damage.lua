-- services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- constants

local EVENTS = ReplicatedStorage:WaitForChild("RuddevEvents")
local MODULES = ReplicatedStorage:WaitForChild("RuddevModules")
	local CONFIG = require(MODULES:WaitForChild("Config"))

local CRIT_MULTIPLIER = 2
local DAMAGE = {}
local BUFF_BULLETSTORM = 1.25
local BUFF_RAGE = 2

function DAMAGE.Calculate(_, item, hit, origin)
	local config = CONFIG:GetConfig(item)
	local damage = config.Damage

	damage = damage * (1 + config.Upgrades / 100)

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
		local crit = false

		if math.random() <= critChance then
			damage = damage * CRIT_MULTIPLIER
			crit = true
		end

		if ReplicatedStorage.CurrentPowerup.Value:match("Rage/") then
			damage = damage * BUFF_RAGE
		elseif ReplicatedStorage.CurrentPowerup.Value:match("Bulletstorm/") then
			damage = damage * BUFF_BULLETSTORM
		end

		if not ReplicatedStorage.HubWorld.Value then
			humanoid:TakeDamage(damage)
		end

		EVENTS.Damaged:Fire(humanoid, damage, player)

		ReplicatedStorage.Remotes.DamageNumber:FireClient(player, humanoid, damage, crit)

		if not ReplicatedStorage.HubWorld.Value then
			for _, otherPlayer in pairs(Players:GetPlayers()) do
				if otherPlayer ~= player then
					ReplicatedStorage.Remotes.DamageNumber:FireClient(otherPlayer, humanoid, damage)
				end
			end
		end
	end
end

return DAMAGE