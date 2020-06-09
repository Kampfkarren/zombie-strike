local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local Promise = require(ReplicatedStorage.Core.Promise)

local DEFAULT_INVENTORY_SIZE = 45
local GAME_PASS_SIZE = 135

return function(player)
	if not RunService:IsRunning() then
		return Promise.resolve(DEFAULT_INVENTORY_SIZE)
	end

	return GamePasses.PlayerOwnsPassAsync(player, GamePassDictionary.MoreItems)
		:andThen(function(owns)
			return owns and GAME_PASS_SIZE or DEFAULT_INVENTORY_SIZE
		end)
end
