local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BULLETSTORM_BUFF = 0.75
local INVINCIBILITY_TIME = 0.75
local MOBILE_DAMAGE_BUFF = 0.5

local lastInvincible = {}

return function(player, damage)
	if tick() - (lastInvincible[player] or 0) <= INVINCIBILITY_TIME then
		return
	end

	lastInvincible[player] = tick()
	local character = player.Character

	if player:FindFirstChild("MobileDamageBuff") then
		damage = damage * MOBILE_DAMAGE_BUFF
	end

	if ReplicatedStorage.CurrentPowerup.Value:match("Bulletstorm/") then
		damage = damage * BULLETSTORM_BUFF
	elseif ReplicatedStorage.CurrentPowerup.Value:match("Tank/") then
		return
	end

	if character then
		character.Humanoid:TakeDamage(damage)
	end
end
