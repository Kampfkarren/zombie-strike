local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local t = require(ReplicatedStorage.Vendor.t)

local Friends = {}

local friendsCache = {}

-- This should be used to check if *friend* gets special access to *player*
-- The server trusts the player on who their friends are, but if you check
-- the other way around, then bad people can go into private only games.
function Friends.IsFriendsWith(friend, player)
	if true then
		return true
	end

	if RunService:IsClient() then
		player = Players.LocalPlayer
	end

	local cache = friendsCache[player]
	if not cache then
		cache = {}
		friendsCache[player] = cache
	end

	if cache[player] == nil then
		cache[player] = player:IsFriendsWith(friend.UserId)
	end

	return cache[player]
end

if RunService:IsClient() then
	local function connectGetCore(name, callback)
		spawn(function()
			while true do
				local value = StarterGui:GetCore(name)
				if value then
					value.Event:connect(callback)
					return
				end

				RunService.Heartbeat:wait()
			end
		end)
	end

	connectGetCore("PlayerFriendedEvent", function(player)
		ReplicatedStorage.Remotes.FriendsWith:FireServer(player, true)
	end)

	connectGetCore("PlayerUnfriendedEvent", function(player)
		ReplicatedStorage.Remotes.FriendsWith:FireServer(player, false)
	end)
else
	ReplicatedStorage.Remotes.FriendsWith.OnServerEvent:connect(function(player, newFriend, value)
		if not t.boolean(value) then
			warn("FriendsWith: not true/false")
			return
		end

		if not t.instanceIsA("Player")(newFriend) then
			warn("FriendsWith: newFriend is not a player")
			return
		end

		if friendsCache[player] == nil then
			friendsCache[player] = {}
		end

		friendsCache[player][newFriend] = value
	end)
end

Players.PlayerRemoving:connect(function(player)
	friendsCache[player] = nil
end)

return Friends
