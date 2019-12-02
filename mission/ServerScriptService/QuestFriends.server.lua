local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)

local GiveQuest = ServerStorage.Events.GiveQuest

local playedWithFriend = {}

Players.PlayerAdded:connect(function(player)
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		FastSpawn(function()
			if player ~= otherPlayer
				and player:IsFriendsWith(otherPlayer.UserId)
				and not playedWithFriend[player]
			then
				playedWithFriend[player] = true

				if not playedWithFriend[otherPlayer] then
					playedWithFriend[otherPlayer] = true
					GiveQuest:Fire(otherPlayer, "PlayMissionWithFriend", 1)
				end
			end
		end)
	end
end)
