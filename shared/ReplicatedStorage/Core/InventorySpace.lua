local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Core.Promise)

local DEFAULT_INVENTORY_SIZE = 30

local inventorySpacePromises = {}

return function(player)
	if not inventorySpacePromises[player] then
		inventorySpacePromises[player] = Promise.resolve(DEFAULT_INVENTORY_SIZE)
	end

	return inventorySpacePromises[player]
end
