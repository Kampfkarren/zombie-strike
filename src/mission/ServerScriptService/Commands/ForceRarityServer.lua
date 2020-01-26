local ServerStorage = game:GetService("ServerStorage")

return function(_, rarity)
	if rarity >= 1 and rarity <= 5 then
		ServerStorage.ForceRarity.Value = rarity
		return "Set rarity"
	else
		return "Rarity is not valid (1 - 5)"
	end
end
