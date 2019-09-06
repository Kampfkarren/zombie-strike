local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Core.Promise)

local RETRY_TIME = 1

local userThumbnails = {}

local function playerAdded(player)
	userThumbnails[player] = Promise.new(function(resolve)
		coroutine.wrap(function()
			while true do
				local thumbnail, finished = Players:GetUserThumbnailAsync(
					player.UserId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size180x180
				)

				if finished then
					resolve(thumbnail)
					return
				end

				wait(RETRY_TIME)
			end
		end)()
	end)
end

Players.PlayerAdded:connect(playerAdded)
for _, player in pairs(Players:GetPlayers()) do
	playerAdded(player)
end

return function(player)
	return assert(userThumbnails[player])
end
