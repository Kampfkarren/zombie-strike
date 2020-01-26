local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loot = require(ReplicatedStorage.Core.Loot)

local goldMultipliers = {
	1,
	1.25,
	1.5,
	1.75,
	2.25,
}

local base = 10
local scale = 1.2

return function(item)
	if Loot.IsAttachment(item) or Loot.IsPet(item) then
		return 0
	else
		return math.floor(base * (scale ^ (item.Level - 1)) * goldMultipliers[item.Rarity])
	end
end
