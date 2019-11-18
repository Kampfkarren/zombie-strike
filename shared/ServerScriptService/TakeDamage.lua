local MOBILE_DAMAGE_BUFF = 0.5

return function(player, damage)
	local character = player.Character

	if player:FindFirstChild("MobileDamageBuff") then
		damage = damage * MOBILE_DAMAGE_BUFF
	end

	if character then
		character.Humanoid:TakeDamage(damage)
	end
end
