-- services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- constants

local EVENTS = ReplicatedStorage:WaitForChild("RuddevEvents")
local MODULES = ReplicatedStorage:WaitForChild("RuddevModules")
	local CONFIG = require(MODULES:WaitForChild("Config"))
local Upgrades = require(ReplicatedStorage.Core.Upgrades)

local CRIT_MULTIPLIER = 2
local DAMAGE = {}
local BUFF_BULLETSTORM = 1.25
local BUFF_RAGE = 2

local damageNumberQueue = {}

-- Combines all damage numbers shot at the same tick into one remote event
-- Used because shotguns will fire a damage number for every pellet hit, which causes bandwidth problems
local function batchDamageNumber(player, humanoid, damage, crit)
	table.insert(damageNumberQueue, { player, humanoid, damage, crit })
	if #damageNumberQueue == 1 then
		local connection

		connection = RunService.Heartbeat:connect(function()
			connection:Disconnect()
			local zombieDamage = {}

			for _, batch in ipairs(damageNumberQueue) do
				local player, humanoid, damage, crit = unpack(batch)

				if not zombieDamage[humanoid] then
					zombieDamage[humanoid] = {
						[player] = { damage, crit },
					}
				elseif not zombieDamage[humanoid][player] then
					zombieDamage[humanoid][player] = { damage, crit }
				else
					local playerDamage = zombieDamage[humanoid][player]
					playerDamage[1] = playerDamage[1] + damage
					if crit then
						playerDamage[2] = true
					end
				end
			end

			for humanoid, playerDamages in pairs(zombieDamage) do
				for player, info in pairs(playerDamages) do
					local damage, crit = unpack(info)
					ReplicatedStorage.Remotes.DamageNumber:FireClient(player, humanoid, damage, crit)

					if not ReplicatedStorage.HubWorld.Value then
						for _, otherPlayer in ipairs(Players:GetPlayers()) do
							if otherPlayer ~= player then
								ReplicatedStorage.Remotes.DamageNumber:FireClient(otherPlayer, humanoid, damage)
							end
						end
					end
				end
			end

			damageNumberQueue = {}
		end)
	end
end

function DAMAGE.Calculate(_, item, hit, origin)
	local config = CONFIG:GetConfig(item)
	local damage = config.Damage

	damage = damage + Upgrades.GetDamageBuff(damage, config.Upgrades)
	damage = damage * (1 + config.Bonus / 100)

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

function DAMAGE.Damage(_, humanoid, damage, player, critChance, lyingDamage)
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

		batchDamageNumber(player, humanoid, lyingDamage or damage, crit)
	end
end

return DAMAGE