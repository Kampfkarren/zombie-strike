local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Core.Promise)
local t = require(ReplicatedStorage.Vendor.t)

local RETRY_TIME = 1

local userThumbnails = {}
local newUserThumbnail = Instance.new("BindableEvent")

local function retrieveAvatar(userId)
	userThumbnails[userId] = Promise.new(function(resolve)
		coroutine.wrap(function()
			while true do
				local thumbnail, finished = Players:GetUserThumbnailAsync(
					userId,
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

local function playerAdded(player)
	retrieveAvatar(player.UserId)
end

Players.PlayerAdded:connect(playerAdded)
for _, player in pairs(Players:GetPlayers()) do
	playerAdded(player)
end

return function(player)
	local userId

	if t.instanceIsA("Player")(player) then
		userId = player.UserId
	elseif typeof(player) == "number" then
		userId = player
	else
		error("unknown type: " .. typeof(player))
	end

	if not userThumbnails[userId] then
		return Promise.async(function(resolve)
			if Players:GetPlayerByUserId(userId) == nil then
				retrieveAvatar(userId)
			end

			while not userThumbnails[userId] do
				newUserThumbnail.Event:wait()
			end

			userThumbnails[userId]:andThen(resolve)
		end)
	end

	return userThumbnails[userId]
end
