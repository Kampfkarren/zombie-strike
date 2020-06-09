local SELL_COSTS = { 60, 150, 245, 350, 550 }

return function(item)
	return SELL_COSTS[item.Rarity]
end
