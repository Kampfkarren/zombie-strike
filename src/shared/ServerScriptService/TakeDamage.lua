local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Perks = require(ReplicatedStorage.Core.Perks)

local BULLETSTORM_BUFF = 0.75
local DEATH_BUFF_INTERVAL = 0.075
local DEATH_BUFF_MAX = 5
local INVINCIBILITY_TIME = 0.75
local MOBILE_DAMAGE_BUFF = 0.5

local deathCounts = {}
local lastInvincible = {}

return function(player, damage)
	if tick() - (lastInvincible[player] or 0) <= INVINCIBILITY_TIME then
		return
	end

	local character = player.Character
	if character and character.Humanoid.Health <= 0 then
		return
	end

	lastInvincible[player] = tick()

	if player:FindFirstChild("MobileDamageBuff") then
		damage = damage * MOBILE_DAMAGE_BUFF
	else
		damage = damage * (1 - DEATH_BUFF_INTERVAL * (deathCounts[player] or 0))
	end

	for _, perk in ipairs(Perks.GetPerksFor(player)) do
		damage = perk:ModifyDamageTaken(damage)
	end

	if ReplicatedStorage.CurrentPowerup.Value:match("Bulletstorm/") then
		damage = damage * BULLETSTORM_BUFF
	elseif ReplicatedStorage.CurrentPowerup.Value:match("Tank/") then
		return
	end

	if CollectionService:GetTagged("Boss")[1] ~= nil then
		ServerStorage.Events.DamagedByBoss:Fire(player)
	end

	character.Humanoid:TakeDamage(damage)
	if character.Humanoid.Health <= 0 then
		deathCounts[player] = math.min(DEATH_BUFF_MAX, (deathCounts[player] or 0) + 1)
	end
end
