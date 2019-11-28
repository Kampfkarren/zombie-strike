local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)

local DEFAULT_INVENTORY_SIZE = 30
local GAME_PASS_SIZE = 100

return function(player)
	return GamePasses.PlayerOwnsPassAsync(player, GamePassDictionary.MoreItems)
		:andThen(function(owns)
			return owns and GAME_PASS_SIZE or DEFAULT_INVENTORY_SIZE
		end)
end
