local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Core.Promise)
local t = require(ReplicatedStorage.Vendor.t)

local RETRY_TIME = 1

local userThumbnails = {}
local newUserThumbnail = Instance.new("BindableEvent")

local function playerAdded(player)
	userThumbnails[player.UserId] = Promise.new(function(resolve)
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
	assert(t.instanceIsA("Player")(player))

	if not userThumbnails[player.UserId] then
		return Promise.async(function(resolve)
			while not userThumbnails[player.UserId] do
				newUserThumbnail.Event:wait()
			end

			userThumbnails[player.UserId]:andThen(resolve)
		end)
	end

	return userThumbnails[player.UserId]
end
